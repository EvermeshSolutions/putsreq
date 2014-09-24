module ApplicationHelper
  def dispatcher_route
    controller_name = controller_path.gsub(/\//, "_")
    "#{controller_name}##{action_name}"
  end

  def token_url(token)
    "#{request.protocol}#{request.host_with_port}/#{token}"
  end

  def show_no_requests_found(bucket)
    if bucket.requests_count > 0
      content_tag(:p, "Oops... You received #{bucket.requests_count} requests, but they were already expired. Make more requests!")
    else
      content_tag(:p, 'No requests received. Run the cURL above to start having fun!')
    end
  end
end
