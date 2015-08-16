class TrackEvent
  include Interactor

  def call
    return unless ENV['GA']

    options = {
      hostname:    rack_request.host,
      path:        rack_request.path,
      user_id:     rack_request.session.id,
      user_ip:     rack_request.remote_ip,
      user_agent:  rack_request.user_agent,
      referrer:    rack_request.referer
    }

    tracker = Staccato.tracker(ENV['GA'], nil, options)

    event = tracker.build_event(category: 'Requests',
                                action: 'record',
                                label: "#{bucket.name} - #{bucket.token}",
                                non_interactive: true)

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
