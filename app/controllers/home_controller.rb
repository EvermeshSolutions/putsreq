class HomeController < ApplicationController
  def index
    @buckets = Bucket.where(owner_token: owner_token).order(:created_at.desc).limit(20)
  end
end
