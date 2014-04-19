class PutsReq
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :requests, dependent: :delete

  field :response_builder, default: -> { default_response_builder }


  def record_request(request)
    requests.create(body:            request.body.read,
                    content_length:  request.content_length,
                    request_method:  request.request_method,
                    ip:              request.ip,
                    url:             request.url,
                    headers:         parse_env_to_headers(request.env),
                    params:          request.params)
  end

  def build_response(req)
    context = V8::Context.new timeout: 10
    context['response'] = { 'status' => 200, 'headers' => {}, 'body' => 'ok' }
    context['request']  = { 'body' => req.body, 'headers' => req.headers }
    context.eval(response_builder.to_s)
    resp = context.eval('JSON.stringify(response)')

    resp = JSON.parse(resp).
      reverse_merge(default_response)

    req.update_attribute :response, resp

    resp
  rescue => e
    { 'status'  => 500,
      'headers' => { 'Content-Type' => 'text/plain' },
      'body'    => e.message }
  end

  private

  def default_response
    { 'status'  => 200,
      'headers' => { 'Content-Type' => 'text/plain' },
      'body'    => 'ok' }
  end

  def parse_env_to_headers(env)
    # return only uppercase header keys
    env.to_h.select do |header_key, header_value|
      header_key == header_key.upcase
    end
  end

  def default_response_builder
    <<-DEFAULT.strip_heredoc
      response.status = 200;

      response.headers['Content-Type'] = 'application/json';

      // response.body = "{ message: 'Hello World' }"
      var parsedBody = JSON.parse(request.body);

      response.body = { message: parsedBody.message + ' Pablo' };
    DEFAULT
  end
end
