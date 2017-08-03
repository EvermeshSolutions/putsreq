class FilterHeaders
  include Interactor

  BLACKLIST_HEADERS = %w(HOST CF X-REQUEST X-FORWARDED CONNECT-TIME TOTAL-ROUTE-TIME VIA).freeze
  WHITELIST_HEADERS = %w(HTTP_ CONTENT).freeze

  delegate :headers, to: :context

  def call
    context.headers = client_supplied_headers
  end

  private

  def client_supplied_headers
    headers.to_h.each_with_object({}) do |(key, value), h|
      key   = key.to_s
      value = value.to_s

      next unless value.to_s.present?

      next if [key.encoding.name, value.encoding.name] != ['UTF-8', 'UTF-8']

      next unless key.upcase.start_with?(*WHITELIST_HEADERS)

      key = key.sub('HTTP_', '').tr('_', '-')

      next if key.upcase.start_with?(*BLACKLIST_HEADERS)

      h[key] = value
    end
  end
end
