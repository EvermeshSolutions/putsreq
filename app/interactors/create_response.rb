class CreateResponse
  include Interactor


  def call
    v8_ctx = V8::Context.new timeout: timeout

    initialize_context(request, v8_ctx)

    built_request = v8_ctx.eval('JSON.stringify(request)')

    built_request = JSON.parse(built_request)

    if forward_url = built_request['forwardTo']
      # use the response from the forwarded URL
      built_response = forward_to(built_request, forward_url)
    else
      # use the response from the builder
      built_response = v8_ctx.eval('JSON.stringify(response)')
      built_response = JSON.parse(built_response).select { |key, value| %w[status headers body].include?(key) && value.to_s.present? }
    end

    built_response['request'] = request

    context.response = bucket.responses.create(built_response)
  rescue => e
    context.response = bucket.responses.create('request' => request,
                                               'status'  => 500,
                                               'headers' => { 'Content-Type' => 'text/plain' },
                                               'body'    => e.message)
  end

  private

  def forward_to(built_request, forward_url, http_adapter = HTTParty)
    body = if built_request['body'].is_a?(Hash)
             built_request['body'].to_json
           else
             built_request['body'].to_s
           end

    options = { timeout: 5,
                headers: Bucket.forwardable_headers(built_request['headers']),
                body: body }

    response = http_adapter.send(built_request['request_method'].downcase.to_sym, forward_url, options)

    { 'status'  => response.code,
      'headers' => response.headers.to_h.inject({}) { |h, (k, v)| h[k] = v.join; h },
      'body'    => response.body }
  end


  def timeout
    context.timeout ||= 2500
  end

  def bucket
    context.bucket
  end

  def request
    context.request
  end

  def initialize_context(request, v8_ctx)
    v8_ctx['response'] = { 'status'  => 200,
                           'headers' => {},
                           'body'    => 'ok' }

    v8_ctx['request']  = { 'request_method' => request.request_method,
                           'body'           => request.body,
                           'params'         => request.params,
                           'headers'        => request.headers }

    v8_ctx.eval(bucket.response_builder.to_s)
  end
end
