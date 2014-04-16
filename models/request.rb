class Request
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :puts_req

  field :body
  field :headers, type: Hash
  field :content_length
  field :request_method
  field :ip
  field :url
  field :params

  field :response, type: Hash

  default_scope order_by(:created_at.desc)

  validates :puts_req, presence: true

  def self.from_request(request, &block)
    req = new(body: request.body.read,
              content_length: request.content_length,
              request_method: request.request_method,
              ip: request.ip,
              url: request.url,
              headers: parse_env_to_headers(request.env),
              params: request.params)

    yield req

    req.save
    req
  end

  private

  def self.parse_env_to_headers(env)
    # return only uppercase header keys
    env.to_h.select do |header_key, header_value|
      header_key == header_key.upcase
    end
  end
end
