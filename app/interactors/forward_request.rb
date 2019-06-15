class ForwardRequest
  include Interactor

  delegate :built_request, to: :context

  def call
    return unless forward_url = built_request.try(:[], 'forwardTo')

    # use the response from the forwarded URL
    context.built_response = forward_to(built_request, forward_url)
  rescue => e
    context.built_response = { 'status' => 500,
                               'headers' => { 'Content-Type' => 'text/plain' },
                               'body' => e.message }
  end

  private

  def forward_to(built_request, forward_url)
    options = { timeout: 5,
                headers: built_request['headers'],
                body: body }

    forwarded_response = HTTParty.send(built_request['request_method'].downcase.to_sym, forward_url, options)

    { 'status' => forwarded_response.code,
      'headers' => FilterHeaders.call(headers: forwarded_response.headers).headers,
      'body' => forwarded_response.body }
  end

  def body
    if built_request['body'].is_a?(Hash)
      JSON.dump(built_request['body'])
    else
      built_request['body'].to_s
    end
  end
end
