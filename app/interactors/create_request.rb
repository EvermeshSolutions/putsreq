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
    rack_request.env.to_h.each_with_object({}) do |(key, value), h|
      next unless value.to_s.present?
      next unless key.upcase == key

      key = key.sub('HTTP_', '').tr('_', '-')

      next if %w(host transfer-encoding).include? key.downcase

      h[key] = value
    end
  end
end
