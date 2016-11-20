class NotifyCount
  include Interactor

  delegate :bucket, :built_request, to: :context

  def call
    return unless ENV['PUSHER_SECRET'] || ENV['PUSHER_APP_ID']

    Pusher.url = "http://3466d56fe2ef1fdd2943:#{ENV['PUSHER_SECRET']}@api.pusherapp.com/apps/#{ENV['PUSHER_APP_ID']}"

    Pusher["channel_requests_#{bucket.id}"].trigger 'update_count', count: bucket.requests_count
  rescue => e
    Rails.logger.error(e)
  end
end
