class CreateRequest
  include Interactor

  def call
    context.request = bucket.requests.create(body:            rack_request.body.read,
                                             content_length:  rack_request.content_length,
                                             request_method:  rack_request.request_method,
                                             ip:              rack_request.ip,
                                             url:             rack_request.url,
                                             headers:         filter_headers(rack_request.env),
                                             params:          rack_request.request_parameters)
    update_bucket
  end

  private

  def update_bucket
    bucket.atomically do
      now = Time.now
      bucket.inc(requests_count: 1)
      bucket.set(last_request_at: now)
      bucket.set(first_request_at: now) unless bucket.first_request_at
    end
  end

  def filter_headers(env)
    # skips lowercase headers (rack specific headers)
    env.to_h.select { |header_key, _header_value| header_key == header_key.upcase }
  end

  def bucket
    context.bucket
  end

  def rack_request
    context.rack_request
  end
end
