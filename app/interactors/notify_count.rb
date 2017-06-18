class NotifyCount
  include Interactor

  delegate :bucket, :built_request, to: :context
  delegate :token, to: :bucket

  def call
    return unless ENV['PUSHER_URL']

    channel = Pusher["presence-channel_requests_#{token}"]

    return if channel.users.empty?

    channel.trigger(
      'new',
      count: bucket.requests_count,
      request: built_request
    )
  rescue => e
    Rails.logger.error(e)
  end
end
