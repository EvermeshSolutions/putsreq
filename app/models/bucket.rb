require 'httparty'
class Bucket
  include Mongoid::Document
  include Mongoid::Timestamps

  # TODO rename production collection to buckets
  store_in collection: 'puts_reqs'

  has_many :requests,   dependent: :delete,  order: [:created_at.desc]
  has_many :responses,  dependent: :delete,  order: [:created_at.desc]

  field :token
  field :owner_token
  field :response_builder, default: -> { default_response_builder }

  index token: 1
  index owner_token: 1

  before_create :generate_token

  def record_request(request)
    requests.create(body:            request.body.read,
                    content_length:  request.content_length,
                    request_method:  request.request_method,
                    ip:              request.ip,
                    url:             request.url,
                    headers:         parse_env_to_headers(request.env),
                    params:          request.request_parameters)
  end

  def build_response(req, timeout = 5)
    context = V8::Context.new timeout: timeout
    context['response'] = { 'status' => 200, 'headers' => {}, 'body' => 'ok' }
    context['request']  = { 'requestMethod' => req.request_method, 'body' => req.body, 'params' => req.params, 'headers' => req.headers }
    if last_request = previous_request(req)
      context['last_request']  = { 'requestMethod' => last_request.request_method, 'body' => last_request.body, 'params' => last_request.params, 'headers' => last_request.headers }
    end
    context.eval(response_builder.to_s)
    builder_req = context.eval('JSON.stringify(request)')

    builder_req  = JSON.parse(builder_req)

    if forward_url = builder_req['forwardTo']
      # use the forwarded response
      resp = forward_to(builder_req, forward_url)
    else
      # use the response builder
      resp = context.eval('JSON.stringify(response)')
      resp = JSON.parse(resp).select { |key, value| %w[status headers body].include?(key) && !value.nil? }
    end

    resp['request'] = req

    responses.create(resp)
  rescue => e
    responses.create('request' => req,
                     'status'  => 500,
                     'headers' => { 'Content-Type' => 'text/plain' },
                     'body'    => e.message)
  end

  def last_req
    requests.order(:created_at.desc).first
  end

  def last_resp
    responses.order(:created_at.desc).first
  end

  def self.find_by_token(token)
    where(token: token).first
  end

  private

  def previous_request(current_request)
    requests.lt(created_at: current_request.created_at).limit(1).order(:created_at.desc).first
  end

  def forward_to(req, forward_url, http_adapter = HTTParty)
    body = req['body'].is_a?(Hash) ? req['body'].to_json : req['body'].to_s

    options = { body: body, timeout: 5, headers: req['headers'].to_h  }

    resp = http_adapter.send(req['requestMethod'].downcase.to_sym, forward_url, options)

    { 'status' => resp.code, 'headers' => forwardable_headers(resp.headers), 'body' => resp.body}
  end

  def forwardable_headers(headers)
    # TODO Need to investigate which header is causing 502 on Heroku. The forward works, but it doesn't return the forwarded response.
    # HTTP/1.1 502 BAD_GATEWAY
    # Content-Length: 0
    # Connection: keep-alive
    # TODO In development: `curl: (56) Problem (2) in the Chunked-Encoded data`
    headers.to_h.select { |key, value| key.start_with?('x-') || %[content-type].include?(key) }
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

  def default_response_builder
    <<-DEFAULT.strip_heredoc
      // Simulate a response
      response.status = 200;

      response.headers['Content-Type'] = 'application/json';

      // response.body = "{ 'message': 'Hello World' }"
      var parsedBody = JSON.parse(request.body);

      response.body = { 'message': parsedBody.message + ' Pablo' };

      // Forward a request
      // request.forwardTo = 'http://example.com';
    DEFAULT
  end
end
