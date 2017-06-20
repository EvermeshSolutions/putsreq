class NotifyCount
  include Interactor

  delegate :bucket, :built_request, to: :context
  delegate :token, to: :bucket

  def call
    return unless ENV['PUSHER_URL']

    channel = Pusher["channel_requests_#{token}"]

    channel.trigger(
      'new',
      count: bucket.requests_count,
      request: built_request
    )
  rescue => e
    Rails.logger.error(e)
  end
end
