class NotifyCount
  include Interactor

  delegate :bucket, :built_request, to: :context

  def call
    return unless ENV['PUSHER_URL']

    Pusher["channel_requests_#{bucket.token}"].trigger('new',
                                                       count: bucket.requests_count,
                                                       request: built_request)
  rescue => e
    Rails.logger.error(e)
  end
end
