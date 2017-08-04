class CreateRequest
  include Interactor

  delegate :bucket, :rack_request, to: :context

  def call
    context.request = bucket.requests.create(
      body:           body(rack_request),
      content_length: rack_request.content_length,
      request_method: rack_request.request_method,
      ip:             rack_request.ip,
      url:            rack_request.url,
      headers:        FilterHeaders.call(headers: rack_request.env).headers
    )

    context.params = rack_request.request_parameters
  rescue
    Rollbar.scope!(request: context.request)
    raise
  end

  private

  def body(rack_request)
    return 'multipart/form-data' if multipart_form_data?(rack_request)

    body = rack_request.body.read.force_encoding(Encoding::UTF_8)

    body.is_utf8? ? body : nil
  end

  def multipart_form_data?(rack_request)
    rack_request.env['CONTENT_TYPE'].to_s.downcase.include? 'multipart/form-data'
  end
end
