class TrackPageView
  include Interactor

  def call
    return unless ENV['GA']

    options = {
      hostname:    rack_request.host,
      path:        rack_request.path,
      user_ip:     rack_request.remote_ip,
      user_agent:  rack_request.user_agent,
      referrer:    rack_request.referer
    }

    tracker = Staccato.tracker(ENV['GA'], nil, options)

    tracker.pageview(title: bucket.name)

    event = tracker.build_event(category: 'Requests', action: 'record', non_interactive: true)

    event.add_measurement(:request, token: bucket.token)

    event.track!
  rescue => e
    Rails.logger.error(e)
  end

  private

  def bucket
    context.bucket
  end

  def rack_request
    context.rack_request
  end
end
