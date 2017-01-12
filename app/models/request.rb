class Request
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :bucket, touch: true

  has_one :response, dependent: :delete

  field :body
  field :headers, type: Hash
  field :content_length
  field :request_method
  field :ip
  field :url
  field :params, type: Hash

  index bucket_id: 1, created_at: -1

  validates :bucket, presence: true

  after_create :bump_requests_recorded

  def body_as_string
    if json? && body.is_a?(String)
      # See https://github.com/phstc/putsreq/issues/31#issuecomment-271681249
      JSON.pretty_generate(JSON.parse(body))
    elsif body.is_a?(Hash)
      # TODO review this, not sure if it will ever be a Hash
      JSON.pretty_generate(body)
    else
      body.to_s
    end
  rescue
    body.to_s
  end

  def headers_as_string
    JSON.pretty_generate(headers.to_h)
  end

  private

  def json?
    headers['CONTENT-TYPE'] == 'application/json'
  end

  def bump_requests_recorded
    REDIS.incr 'requests_recorded'
  end
end
