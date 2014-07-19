class Request
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :bucket

  has_one :response, dependent: :delete

  field :body
  field :headers, type: Hash
  field :content_length
  field :request_method
  field :ip
  field :url
  field :params, type: Hash

  validates :bucket, presence: true

  after_create :bump_requests_recorded

  private

  def bump_requests_recorded
    REDIS.incr 'requests_recorded'
  end
end
