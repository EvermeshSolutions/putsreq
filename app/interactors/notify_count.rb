class NotifyCount
  include Interactor

  delegate :bucket, :built_request, :built_response, to: :context
  delegate :token, to: :bucket

  def call
    return unless enabled?

    channel_name = "channel_requests_#{token}"
    channel = pusher.channel_info(channel_name)

    return unless channel[:occupied]

    pusher.trigger(
      channel_name,
      'new',
      count: bucket.requests_count,
      id: context.request.id.to_s,
      request: built_request,
      response: built_response
    )
  rescue => e
    Rollbar.error(e, token: token)
  end

  private

  def enabled?
    pusher_url.present?
  end

  def pusher_url
    ENV['PUSHER_URL']
  end

  def pusher
    @_pusher_client ||= Pusher::Client.new(
      app_id: ENV['PUSHER_APP_ID'],
      key: ENV['PUSHER_KEY'],
      secret: ENV['PUSHER_SECRET'],
      cluster: ENV['PUSHER_CLUSTER'],
      encrypted: true
    )
  end
end
