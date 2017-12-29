class Bucket
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :forks, class_name: 'Bucket'

  belongs_to :fork, class_name: 'Bucket', required: false
  belongs_to :user, required: false

  field :token
  field :name
  field :owner_token
  field :response_builder, default: -> { default_response_builder }
  field :history_start_at, type: Time

  # temporally hack
  attr_accessor :request

  index token: 1
  index owner_token: 1
  index fork_id: 1

  index({ updated_at: 1 }, expire_after_seconds: 1.month)

  before_create :generate_token

  def requests
    # I couldn't make has_many + conditions work with Mongoid
    # requests must be filtered by created_at
    # see clear_history

    Request.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.desc)
  end

  def responses
    # I couldn't make has_many + conditions work with Mongoid
    # responses must be filtered by created_at
    # see clear_history

    Response.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.desc)
  end

  def clear_history
    # requests and responses are capped collections in production, we cannot delete docs on a capped collection
    # so we filter these objects by the history_start_at to "clear"
    # db.runCommand({ "convertToCapped": "requests",  size: 25000000 });
    # db.runCommand({ "convertToCapped": "responses", size: 25000000 });
    update_attribute :history_start_at, Time.now
  end

  def name
    if (name = read_attribute(:name)).blank?
      token
    else
      name
    end
  end

  def last_request
    requests.order(:created_at.desc).first
  end

  def last_response
    responses.order(:created_at.desc).first
  end

  def last_request_at
    last_request&.created_at
  end

  def first_request
    requests.order(:created_at.asc).first
  end

  def first_request_at
    first_request&.created_at
  end

  def requests_count
    requests.count
  end

  private

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(15).tr('_-', '0a')
      break random_token unless Bucket.where(token: random_token).exists?
    end
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
