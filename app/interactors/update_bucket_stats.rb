class UpdateBucketStats
  include Interactor

  def call
    bucket.atomically do
      now = Time.now

      bucket.inc(requests_count: 1)
      bucket.set(last_request_at: now)
      bucket.set(first_request_at: now) unless bucket.first_request_at
    end
  end

  private

  def bucket
    context.bucket
  end
end
