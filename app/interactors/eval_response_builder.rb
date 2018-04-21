class EvalResponseBuilder
  include Interactor

  delegate :request, :params, to: :context

  def call
    v8_ctx = V8::Context.new timeout: timeout

    eval_response_builder(v8_ctx)

    eval_request(v8_ctx)

    eval_response(v8_ctx)
  rescue => e
    context.built_response = { 'status'  => 500,
                               'headers' => { 'Content-Type' => 'text/plain' },
                               'body'    => e.message }
  end

  private

  def eval_request(v8_ctx)
    context.built_request = JSON.parse(v8_ctx.eval('JSON.stringify(request)'))
  end

  def eval_response(v8_ctx)
    context.built_response = v8_ctx.eval('JSON.stringify(response)')

    # filter allowed parameters
    context.built_response = JSON.parse(context.built_response).select do |key, value|
      %w[status headers body].include?(key) && value.to_s.present?
    end
  end

  def initialize_response_builder_attrs(v8_ctx)
    v8_ctx['response'] = { 'status'  => 200,
                           'headers' => {},
                           'body'    => 'ok' }

    v8_ctx['request']  = { 'request_method' => request.request_method,
                           'body'           => request.body,
                           'params'         => params,
                           'headers'        => request.headers }
  end

  def eval_response_builder(v8_ctx)
    initialize_response_builder_attrs(v8_ctx)

    v8_ctx.eval(context.bucket.response_builder.to_s)
  end

  def timeout
    context.timeout ||= 2500
  end
end
