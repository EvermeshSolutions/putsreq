class TrackPageView
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

    tracker.pageview(title: bucket.token)
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
