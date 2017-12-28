class BucketSerializer < ActiveModel::Serializer
  attributes :last_request,  :first_request, :requests_count

  def last_request
    RequestSerializer.new(object.last_request)
  end

  def last_request_path
    request_path(object.last_request.id)
  end

  def first_request
    RequestSerializer.new(object.first_request)
  end

  def first_request_path
    request_path(object.first_request.id)
  end

  private

  def request_path(id)
    Rails.application.routes.url_helpers.request_path(token: object.bucket.token, id: id, format: :json)
  end
end
