class CreateOrRetrieveBucket
  include Interactor

  delegate :token, :owner_token, :user_id, to: :context

  def call
    if (bucket = Bucket.where(token: token).first)
      return context.bucket = bucket
    end

    context.bucket = Bucket.create(
      owner_token: owner_token,
      user_id: user_id,
      token: token
    )
  end
end
