class Response
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :bucket
  belongs_to :request

  field :body, default: 'ok'
  field :headers, type: Hash, default: { 'Content-Type' => 'text/plain' }
  field :status, type: Integer, default: 200

  validates :bucket, presence: true
  validates :request,  presence: true

  def body_to_s
    body.is_a?(Hash) ? body.to_json : body.to_s
  end
end
