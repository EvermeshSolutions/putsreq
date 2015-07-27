class ForwardRequest
  include Interactor

  def call
    return unless forward_url = built_request['forwardTo']

    # use the response from the forwarded URL
    context.built_response = forward_to(built_request, forward_url)
  rescue => e
    context.built_response = { 'status'  => 500,
                               'headers' => { 'Content-Type' => 'text/plain' },
                               'body'    => e.message }
  end

  private

  def forward_to(built_request, forward_url)
    body = if built_request['body'].is_a?(Hash)
             built_request['body'].to_json
           else
             built_request['body'].to_s
           end

    options = { timeout: 5,
                headers: Bucket.forwardable_headers(built_request['headers']),
                body: body }

    forwarded_response = HTTParty.send(built_request['request_method'].downcase.to_sym, forward_url, options)

    { 'status'  => forwarded_response.code,
      'headers' => forwarded_response.headers.to_h.each_with_object({}) { |(k, v), h| h[k] = v.join },
      'body'    => forwarded_response.body }
  end

  def built_request
    context.built_request
  end
end
