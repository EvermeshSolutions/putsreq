class RequestSerializer < ActiveModel::Serializer
  attribute :id

  def id
    object.id.to_s
  end
end
