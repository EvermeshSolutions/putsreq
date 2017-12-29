class BucketSerializer < ActiveModel::Serializer
  attributes :requests_count, :path

  belongs_to :request
  belongs_to :first_request
  belongs_to :last_request

  def path
    Rails.application.routes.url_helpers.bucket_path(token: object.token)
  end
end
