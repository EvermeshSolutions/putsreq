class CreateRequest
  include Interactor

  delegate :bucket, :rack_request, to: :context

  def call
    context.request = bucket.requests.create(
      body: body(rack_request),
      content_length: rack_request.content_length,
      request_method: rack_request.request_method,
      ip: rack_request.ip,
      url: rack_request.url,
      headers: FilterHeaders.call(headers: rack_request.env).headers
    )

    context.params = params
  rescue
    Rollbar.scope!(request: context.request)
    raise
  end

  private

  def params
    rack_request.params.to_h.except('controller', 'action', 'token')
  end

  def body(rack_request)
    body = rack_request.body.read.encode('UTF-8', invalid: :replace, undef: :replace)

    body.is_utf8? ? body : nil
  end
end
