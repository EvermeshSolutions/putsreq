class RequestSerializer < ActiveModel::Serializer
  attribute :id
  attribute :headers
  attribute :time_ago_in_words
  attribute :created_at

  def id
    object.id.to_s
  end

  def time_ago_in_words
    "#{ApplicationController.helpers.time_ago_in_words(object.created_at)} ago"
  end
end
