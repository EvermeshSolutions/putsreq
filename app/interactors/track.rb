class Track
  include Interactor

  delegate :bucket, :rack_request, to: :context
  delegate :token, to: :bucket

  def call
    tracker.event(category: 'bucket', action: 'record', label: token, value: 1)
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
    nil
  end

  def tracker
    @_tracker ||= Staccato.tracker('UA-50754009-1', client_id, global_context)
  end
end
