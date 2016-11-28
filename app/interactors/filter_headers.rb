class FilterHeaders
  include Interactor

  delegate :headers, to: :context

  def call
    context.headers = client_supplied_headers
  end

  private

  def client_supplied_headers
    headers.to_h.each_with_object({}) do |(key, value), h|
      next unless value.to_s.present?
      # Only saves user supplied headers HTTP_ or content-type/length
      next unless key.start_with?('HTTP_') || %w(content-type content-length).include?(key.downcase)

      key = key.sub('HTTP_', '').tr('_', '-')

      next if key.start_with? 'CF-' # ignore CloudFare headers

      h[key] = value
    end
  end
end
