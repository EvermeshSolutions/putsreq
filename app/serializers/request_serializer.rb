class RequestSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :headers,
    :time_ago_in_words,
    :created_at,
    :request_method,
    :request_body_as_string,
    :response_body_as_string,
    :headers_as_string,
    :path
  )

  def id
    object.id.to_s
  end

  def time_ago_in_words
    "#{ApplicationController.helpers.time_ago_in_words(object.created_at)} ago"
  end


  def headers_as_string
    JSON.pretty_generate(object.headers.to_h)
  end

  def request_body_as_string
    body_as_string(object)
  end

  def response_body_as_string
    body_as_string(object.response)
  end

  private

  def body_as_string(req_or_res)
    body = req_or_res.body

    if body_json?(req_or_res) && body.is_a?(String)
      # See https://github.com/phstc/putsreq/issues/31#issuecomment-271681249
      return JSON.pretty_generate(JSON.parse(body))
    end

    if body.is_a?(Hash)
      # For responses body can be a hash
      # body.to_h because body can be a BSON::Document
      # which for some reason does format well with
      # pretty_generate
      return JSON.pretty_generate(body.to_h)
    end

    if body.is_a?(Array)
      # see https://github.com/phstc/putsreq/issues/33
      return JSON.pretty_generate(body.to_a)
    end

    body.to_s
  rescue
    body.to_s
  end

  def body_json?(req_or_res)
    req_or_res.headers.to_h.each do |key, value|
      return !!(value =~ /application\/json/i) if key =~ /^content-type$/i
    end

    false
  end
end
