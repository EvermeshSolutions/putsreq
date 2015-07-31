class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :is_owner?

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def check_ownership!
    unless is_owner?(bucket)
      redirect_to bucket_path(bucket.token), alert: 'Only the bucket owner can perform this operation'
    end
  end

  def is_owner?(bucket)
    owner_token == bucket.owner_token || (user_signed_in? && bucket.user == current_user)
  end

  def owner_token
    cookies[:owner_token] ||= { value: SecureRandom.hex(24), expires: 1.year.from_now }
  end

  def bucket
    @bucket ||= Bucket.find_by(token: params[:token])
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
  end
end
