class Response
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :puts_req
  belongs_to :request

  field :body, default: 'ok'
  field :headers, type: Hash, default: { 'Content-Type' => 'text/plain' }
  field :status, type: Integer, default: 200

  default_scope order_by(:created_at.desc)

  validates :puts_req, presence: true
  validates :request,  presence: true
end
