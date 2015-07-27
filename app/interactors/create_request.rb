class CreateRequest
  include Interactor

  def call
    context.request = bucket.requests.create(body:            rack_request.body.read,
                                             content_length:  rack_request.content_length,
                                             request_method:  rack_request.request_method,
                                             ip:              rack_request.ip,
                                             url:             rack_request.url,
                                             headers:         filtered_headers,
                                             params:          rack_request.request_parameters)
  end

  private

  def filtered_headers
    # skip lowercase headers (rack specific headers)
    rack_request.env.to_h.select { |key, _value| key == key.upcase }
  end

  def bucket
    context.bucket
  end

  def rack_request
    context.rack_request
  end
end
