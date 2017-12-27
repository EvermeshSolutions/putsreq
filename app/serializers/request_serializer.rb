class RequestSerializer < ActiveModel::Serializer
  attributes :id, :headers, :time_ago_in_words, :created_at

  def id
    object.id.to_s
  end

  def time_ago_in_words
    "#{ApplicationController.helpers.time_ago_in_words(object.created_at)} ago"
  end
end
