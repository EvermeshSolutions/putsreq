class Response
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :bucket
  belongs_to :request

  field :body, default: 'ok'
  field :headers, type: Hash, default: { 'Content-Type' => 'text/plain' }
  field :status, type: Integer, default: 200

  # index created_at: 1, options { expireAfterSeconds: 604800 }
  index bucket_id: 1, created_at: -1
  index request_id: 1

  validates :bucket, presence: true
  validates :request,  presence: true

  def body_as_string
    body.is_a?(Hash) ? body.to_json : body.to_s
  end
end
