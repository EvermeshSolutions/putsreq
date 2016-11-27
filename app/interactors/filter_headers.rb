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
      next unless key.upcase == key

      key = key.sub('HTTP_', '').tr('_', '-')

      next if key.upcase.start_with? 'CF-' # Ignore CloudFlare headers
      next if key.upcase.start_with? 'SERVER-'

      next if %w(host transfer-encoding).include? key.downcase

      h[key] = value
    end
  end
end
