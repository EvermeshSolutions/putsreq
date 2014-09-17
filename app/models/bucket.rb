require 'httparty'
class Bucket
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :forks, class_name: 'Bucket'

  belongs_to :fork, class_name: 'Bucket'

  field :token
  field :name
  field :owner_token
  field :response_builder, default: -> { default_response_builder }
  field :last_request_at, type: Time
  field :history_start_at, type: Time

  index token: 1
  index owner_token: 1

  before_create :generate_tokens

  def requests
    # couldn't make has_many + conditions work with Mongoid
    # requests must be filtered by created_at see `clear_history`
    Request.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.asc)
  end

  def responses
    # couldn't make has_many + conditions work with Mongoid
    # responses must be filtered by created_at see `clear_history`
    Response.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.asc)
  end

  def clear_history
    # requests and responses are capped collections in production, we cannot delete docs on a capped collection
    # so we filter these objects by the history_start_at to "clear"
    # db.runCommand({ "convertToCapped": "requests",  size: 25000000 });
    # db.runCommand({ "convertToCapped": "responses", size: 25000000 });
    update_attribute :history_start_at, Time.now
  end

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

  def build_response(request, timeout = 2500)
    context = V8::Context.new timeout: timeout

    load_default_record(request, context)

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

  def requests_count
    requests.count
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

    options = { timeout: 5,
                headers: forwardable_request_headers(request_hash['headers']),
                body: body }

    response = http_adapter.send(request_hash['request_method'].downcase.to_sym, forward_url, options)

    { 'status'  => response.code,
      'headers' => forwardable_response_headers(response.headers),
      'body'    => response.body }
  end

  def forwardable_request_headers(headers)
    headers.to_h.reject do |key, value|
      value.nil?
    end.inject({}) do |headers, (key, value)|
      headers[key.gsub(/^HTTP_/i, '')] = value
      headers
    end
  end

  def forwardable_response_headers(headers)
    headers.to_h.select do |key, value|
      key = key.downcase
      key.start_with?('x-') || %[content-type].include?(key)
    end.inject({}) do |headers, (key, value)|
      headers[key] = value.join
      headers
    end
  end

  def generate_tokens
    self.token = generate_token(:token)
  end

  def generate_token(attr)
    loop do
      random_token = SecureRandom.urlsafe_base64(15).tr('_-', '0a')
      break random_token unless Bucket.where(attr => random_token).exists?
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
