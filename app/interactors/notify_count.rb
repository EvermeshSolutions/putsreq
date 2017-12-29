class NotifyCount
  include Interactor

  delegate :bucket, :built_request, :built_response, to: :context
  delegate :token, to: :bucket

  def call
    return unless ENV['PUSHER_URL']

    channel_name = "channel_requests_#{token}"
    channel = pusher_client.channel_info(channel_name)

    return unless channel[:occupied]

    pusher_client.trigger(
      channel_name,
      'new',
      count: bucket.requests_count,
      id: context.request.id.to_s,
      request: built_request,
      response: built_response
    )
  rescue => e
    Rails.logger.error(e)
  end

  private

  def pusher_client
    @_pusher_client ||= Pusher::Client.new(
      app_id: ENV['PUSHER_APP_ID'],
      key: ENV['PUSHER_KEY'],
      secret: ENV['PUSHER_SECRET'],
      cluster: ENV['PUSHER_CLUSTER'],
      encrypted: true
    )
  end
end
