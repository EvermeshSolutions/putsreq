class HomeController < ApplicationController
  def index
    if user_signed_in?
      selector = Bucket.or([user: current_user], [owner_token: owner_token])
    else
      selector = Bucket.where(owner_token: owner_token)
    end

    @buckets = selector.order(:created_at.desc).limit(20)
  end
end
