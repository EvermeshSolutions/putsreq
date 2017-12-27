class NotifyCount
  include Interactor

  delegate :bucket, :built_request, :built_response, to: :context
  delegate :token, to: :bucket

  def call
    return unless ENV['PUSHER_URL']

    channel = Pusher["channel_requests_#{token}"]

    return unless channel.info[:occupied]

    channel.trigger(
      'new',
      count: bucket.requests_count,
      id: context.request.id,
      request: built_request,
      response: built_response
    )
  rescue => e
    Rails.logger.error(e)
  end
end
