class NotifyCount
  include Interactor

  delegate :bucket, :built_request, to: :context

  def call
    return unless ENV['PUSHER_URL']

    Pusher["channel_requests_#{bucket.id}"].trigger 'update_count', bucket.requests_count
  rescue => e
    Rails.logger.error(e)
  end
end
