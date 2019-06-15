module ApplicationHelper
  def dispatcher_route
    controller_name = controller_path.gsub(/\//, '_')
    "#{controller_name}##{action_name}"
  end

  def token_url(token)
    "#{request.protocol}#{request.host_with_port}/#{token}"
  end

  def show_no_requests_found(_bucket)
    content_tag(:p, 'No requests found.')
  end

  def requests_recorded
    number_with_delimiter(Rails.cache.fetch('requests_recorded', raw: true) { 0 })
  end
end
