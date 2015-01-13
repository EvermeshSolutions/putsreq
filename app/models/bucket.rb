require 'httparty'
class Bucket
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :forks, class_name: 'Bucket'

  belongs_to :fork, class_name: 'Bucket'
  belongs_to :user

  field :token
  field :name
  field :owner_token
  field :response_builder, default: -> { default_response_builder }
  field :last_request_at, type: Time
  field :first_request_at, type: Time
  field :history_start_at, type: Time
  field :requests_count, type: Integer, default: 0

  index token: 1
  index owner_token: 1
  index fork_id: 1

  before_create :generate_tokens

  def requests
    # couldn't make has_many + conditions work with Mongoid
    # requests must be filtered by created_at see `clear_history`

    # Avoid kaminari `.count` they are too expensive
    r = Request.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.desc)
    r.instance_variable_set :@requests_count, requests_count
    r.instance_eval do
      def total_count
        @requests_count
      end
    end
    r
  end

  def responses
    # couldn't make has_many + conditions work with Mongoid
    # responses must be filtered by created_at see `clear_history`
    Response.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.desc)
  end

  def clear_history
    # requests and responses are capped collections in production, we cannot delete docs on a capped collection
    # so we filter these objects by the history_start_at to "clear"
    # db.runCommand({ "convertToCapped": "requests",  size: 25000000 });
    # db.runCommand({ "convertToCapped": "responses", size: 25000000 });
    update_attributes(history_start_at: Time.now,
                      first_request_at: nil,
                      last_request_at: nil,
                      requests_count: 0)
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

    atomically do
      inc(requests_count: 1)
      set(last_request_at: Time.now)
      set(first_request_at: Time.now) unless first_request_at
    end

    request
  end

  def build_response(request, timeout = 2500)
    context = V8::Context.new timeout: timeout

    initialize_context(request, context)

    built_request = context.eval('JSON.stringify(request)')

    built_request = JSON.parse(built_request)

    if forward_url = built_request['forwardTo']
      # use the response from the forwarded URL
      built_response = forward_to(built_request, forward_url)
    else
      # use the response from the builder
      built_response = context.eval('JSON.stringify(response)')
      built_response = JSON.parse(built_response).select { |key, value| %w[status headers body].include?(key) && value.to_s.present? }
    end

    built_response['request'] = request

    responses.create(built_response)
  rescue => e
    Rails.logger.error e

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

  # TODO Move to something else i.e. concerns/ForwardableHTTP
  def self.forwardable_headers(headers)
    headers.to_h.reject do |key, value|
      value.nil? || key.downcase.include?('host')
    end.inject({}) do |headers, (key, value)|
      headers[key.sub('HTTP_', '')] = value
      headers
    end
  end

  private

  def previous_request(current_request)
    requests.lt(created_at: current_request.created_at).limit(1).order(:created_at.desc).first
  end

  def forward_to(built_request, forward_url, http_adapter = HTTParty)
    body = if built_request['body'].is_a?(Hash)
             built_request['body'].to_json
           else
             built_request['body'].to_s
           end

    options = { timeout: 5,
                headers: Bucket.forwardable_headers(built_request['headers']),
                body: body }

    response = http_adapter.send(built_request['request_method'].downcase.to_sym, forward_url, options)

    { 'status'  => response.code,
      'headers' => response.headers.to_h.inject({}) { |h, (k, v)| h[k] = v.join; h },
      'body'    => response.body }
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

  def initialize_context(request, context)
    context['response'] = { 'status'  => 200,
                            'headers' => {},
                            'body'    => 'ok' }

    context['request']  = { 'request_method' => request.request_method,
                            'body'           => request.body,
                            'params'         => request.params,
                            'headers'        => request.headers }

    context.eval(response_builder.to_s)
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
