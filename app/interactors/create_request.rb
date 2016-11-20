class CreateRequest
  include Interactor

  delegate :bucket, :rack_request, to: :context

  def call
    context.request = bucket.requests.create(body:            rack_request.body.read,
                                             content_length:  rack_request.content_length,
                                             request_method:  rack_request.request_method,
                                             ip:              rack_request.ip,
                                             url:             rack_request.url,
                                             headers:         client_supplied_headers,
                                             params:          rack_request.request_parameters)
  end

  private

  def client_supplied_headers
    # See HTTP_ Variables
    # http://www.rubydoc.info/github/rack/rack/file/SPEC
    headers = rack_request.env.to_h.select { |key, _value| key.upcase.start_with? 'HTTP_' }

    headers.each_with_object({}) do |(key, value), h|
      next unless value.to_s.present?
      # See http://www.andhapp.com/blog/2013/03/03/rack-nginx-custom-http-header-http_-and-_/
      h[key.sub('HTTP_', '').gsub('_', '-')] = value
    end
  end
end
