class Track
  include Interactor

  delegate :bucket, :rack_request, to: :context
  delegate :token, to: :bucket

  def call
    return unless enabled?

    tracker.event(category: 'bucket', action: 'record', label: token, value: 1, non_interactive: true)
  rescue => e
    Rollbar.error(e, token: token)
  end

  private

  def global_context
    {
      user_ip: rack_request.ip,
      ssl: true,
      user_agent: rack_request.user_agent
    }
  end

  def client_id
    # since there's no identification in the requests,
    # the only way to aggregate requests per "user" is per ip
    # https://stackoverflow.com/a/31854739/464685
    rack_request.ip
  end

  def enabled?
    google_analytics_tracking_id.present?
  end

  def google_analytics_tracking_id
    ENV['GOOGLE_ANALYTICS_TRACKING_ID']
  end

  def tracker
    @_tracker ||= Staccato.tracker(google_analytics_tracking_id, client_id, global_context)
  end
end