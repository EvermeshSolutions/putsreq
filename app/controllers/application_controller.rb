class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :is_owner?

  protected

  def check_ownership!
    unless is_owner?(bucket)
      redirect_to bucket_path(bucket.token), alert: 'Only the bucket owner can perform this operation'
    end
  end

  def is_owner?(bucket)
    owner_token == bucket.owner_token
  end

  def owner_token
    cookies[:owner_token] ||= { value: SecureRandom.hex(24), expires: 1.year.from_now }
  end

  def bucket
    @bucket ||= Bucket.where(token: params[:token]).first
  end
end
