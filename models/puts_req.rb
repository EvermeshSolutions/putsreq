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

  private

  def parse_env_to_headers(env)
    # return only uppercase header keys
    env.to_h.select do |header_key, header_value|
      header_key == header_key.upcase
    end
  end

  def default_response_builder
    %{response.code = 200;
response.headers['Content-Type'] = 'application/json';

// response.body = "{ message: 'Hello World' }"
var parsedBody = JSON.parse(request.body);

response.body = { message: parsedBody.message + ' Pablo' };}
  end
end
