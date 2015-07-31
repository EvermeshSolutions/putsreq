class NotifyCount
  include Interactor

  def call
    return unless ENV['PUSHER_SECRET'] || ENV['PUSHER_APP_ID']

    Pusher.url = "http://3466d56fe2ef1fdd2943:#{ENV['PUSHER_SECRET']}@api.pusherapp.com/apps/#{ENV['PUSHER_APP_ID']}"

    Pusher["channel_#{bucket.token}"].trigger 'update_count', bucket.requests_count
  end

  private

  def bucket
    context.bucket
  end
end
