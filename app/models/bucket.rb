require 'httparty'
class Bucket
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :forks, class_name: 'Bucket'

  belongs_to :fork, class_name: 'Bucket'
  belongs_to :user

  field :token
  field :name
  field :owner_token
  field :response_builder, default: -> { default_response_builder }
  field :last_request_at, type: Time
  field :first_request_at, type: Time
  field :history_start_at, type: Time
  field :requests_count, type: Integer, default: 0

  index token: 1
  index owner_token: 1
  index fork_id: 1

  before_create :generate_tokens

  def requests
    # I couldn't make has_many + conditions work with Mongoid
    # requests must be filtered by created_at
    # see clear_history

    # Avoid kaminari `.count` they are too expensive
    r = Request.where(bucket_id: id).gte(created_at: history_start_at || created_at).order(:created_at.desc)
    r.instance_variable_set :@requests_count, requests_count
    r.instance_eval do
      def total_count
        @requests_count
      end
    end
    r
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
    update_attributes(history_start_at: Time.now,
                      first_request_at: nil,
                      last_request_at: nil,
                      requests_count: 0)
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

  def self.find_by_token(token)
    where(token: token).first
  end

  # TODO Move to something else i.e. concerns/ForwardableHTTP
  def self.forwardable_headers(headers)
    headers.to_h.reject do |key, value|
      value.nil? || key.downcase.include?('host')
    end.each_with_object({}) do |(key, value), new_headers|
      new_headers[key.sub('HTTP_', '')] = value
    end
  end

  private

  def previous_request(current_request)
    requests.lt(created_at: current_request.created_at).limit(1).order(:created_at.desc).first
  end

  def generate_tokens
    self.token = generate_token(:token)
  end

  def generate_token(attr)
    loop do
      random_token = SecureRandom.urlsafe_base64(15).tr('_-', '0a')
      break random_token unless Bucket.where(attr => random_token).exists?
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
