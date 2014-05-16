require 'httparty'
class Bucket
  include Mongoid::Document
  include Mongoid::Timestamps

  # TODO rename production collection to buckets
  store_in collection: 'puts_reqs'

  has_many :requests,   dependent: :delete,  order: [:created_at.desc]
  has_many :responses,  dependent: :delete,  order: [:created_at.desc]

  field :token
  field :name
  field :owner_token
  field :response_builder, default: -> { default_response_builder }
  field :last_request_at, type: Time

  index token: 1
  index owner_token: 1

  before_create :generate_token

  def name
    if (name = read_attribute(:name)).blank?
      token
    else
      name
    end
  end

  def record_request(rack_request)
    request = requests.create(body:            rack_request.body.read,
                              content_length:  rack_request.content_length,
                              request_method:  rack_request.request_method,
                              ip:              rack_request.ip,
                              url:             rack_request.url,
                              headers:         parse_env_to_headers(rack_request.env),
                              params:          rack_request.request_parameters)

    update_attribute :last_request_at, Time.now

    request
  end

  def build_response(request, timeout = 10)
    context = V8::Context.new timeout: timeout

    load_default_record(request, context)
    load_last_record(request, context)

    context.eval(response_builder.to_s)

    request_hash = context.eval('JSON.stringify(request)')

    request_hash  = JSON.parse(request_hash)

    if forward_url = request_hash['forwardTo']
      # use the forwarded response
      response_hash = forward_to(request_hash, forward_url)
    else
      # use the response builder
      response_hash = context.eval('JSON.stringify(response)')
      response_hash = JSON.parse(response_hash).select { |key, value| %w[status headers body].include?(key) && value.to_s.present? }
    end

    response_hash['request'] = request

    responses.create(response_hash)
  rescue => e
    responses.create('request' => request,
                     'status'  => 500,
                     'headers' => { 'Content-Type' => 'text/plain' },
                     'body'    => e.message)
  end

  def last_request
    requests.order(:created_at.desc).first
  end

  def last_response
    responses.order(:created_at.desc).first
  end

  def self.find_by_token(token)
    where(token: token).first
  end

  private

  def previous_request(current_request)
    requests.lt(created_at: current_request.created_at).limit(1).order(:created_at.desc).first
  end

  def forward_to(request_hash, forward_url, http_adapter = HTTParty)
    body = if request_hash['body'].is_a?(Hash)
             request_hash['body'].to_json
           else
             request_hash['body'].to_s
           end

    options = { timeout: 5, headers: request_hash['headers'].to_h, body: body }

    response = http_adapter.send(request_hash['request_method'].downcase.to_sym, forward_url, options)

    { 'status'  => response.code,
      'headers' => forwardable_headers(response.headers),
      'body'    => response.body }
  end

  def forwardable_headers(headers)
    headers.to_h.select do |key, value|
      key = key.downcase
      key.start_with?('x-') || %[content-type].include?(key)
    end
  end

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(15).tr('_-', '0a')
      break random_token unless Bucket.where(token: random_token).exists?
    end
  end

  def parse_env_to_headers(env)
    # return only uppercase header keys
    env.to_h.select do |header_key, header_value|
      header_key == header_key.upcase
    end
  end

  def load_default_record(request, context)
    context['response'] = { 'status'  => 200,
                            'headers' => {},
                            'body'    => 'ok' }

    context['request']  = { 'request_method' => request.request_method,
                            'body'           => request.body,
                            'params'         => request.params,
                            'headers'        => request.headers }
  end

  def load_last_record(request, context)
    if last_request = previous_request(request)
      last_response = last_request.response

      context['last_request']  = { 'created_at'     => last_request.created_at,
                                   'request_method' => last_request.request_method,
                                   'body'           => last_request.body,
                                   'params'         => last_request.params,
                                   'headers'        => last_request.headers }

      context['last_response'] = { 'created_at' => last_response.created_at,
                                   'status'     => last_response.status,
                                   'headers'    => last_response.headers,
                                   'body'       => last_response.body }
    else
      context['last_request']  = nil
      context['last_response'] = nil
    end
  end

  def default_response_builder
    <<-DEFAULT.strip_heredoc
      // Build a response
      var msg = 'Hello World';

      if(request.params.name) {
        msg = 'Hello ' + request.params.name;
      }

      response.body = msg;

      // Forward a request
      // request.forwardTo = 'http://example.com/api';
    DEFAULT
  end
end
