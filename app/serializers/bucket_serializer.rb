class BucketSerializer < ActiveModel::Serializer
  attributes :first_request_at, :last_request_at, :first_request_path, :first_request_id

  has_many :requests

  def first_request_id
    return unless object.requests.first

    object.requests.first.id.to_s
  end

  def first_request_path
    return unless first_request_id

    Rails.application.routes.url_helpers.request_path(token: object.token, id: first_request_id, format: :json)
  end
end
