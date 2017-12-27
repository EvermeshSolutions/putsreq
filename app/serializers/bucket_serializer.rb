class BucketSerializer < ActiveModel::Serializer
  attributes :first_request_at, :last_request_at
end
