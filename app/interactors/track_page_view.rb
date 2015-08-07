class TrackPageView
  include Interactor

  def call
    return unless ENV['GA'] || ENV['GA_HOSTNAME']

    tracker = Staccato.tracker(ENV['GA'])

    tracker.pageview(path: "/#{bucket.token}", hostname: ENV['GA_HOSTNAME'], title: bucket.name)
  rescue => e
    Rails.logger.error(e)
  end

  private

  def bucket
    context.bucket
  end
end
