class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :is_owner?, :body_as_string, :headers_as_string

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def body_as_string(req_or_res)
    body = req_or_res.body

    if body_json?(req_or_res) && body.is_a?(String)
      # See https://github.com/phstc/putsreq/issues/31#issuecomment-271681249
      JSON.pretty_generate(JSON.parse(body))
    elsif body.is_a?(Hash)
      # For responses body can be a hash
      # body.to_h because body can be a BSON::Document
      # which for some reason does format well with
      # pretty_generate
      JSON.pretty_generate(body.to_h)
    else
      body.to_s
    end
  rescue
    body.to_s
  end

  def headers_as_string(req_or_res)
    JSON.pretty_generate(req_or_res.headers.to_h)
  end

  def body_json?(req_or_res)
    req_or_res.headers.to_h.each do |key, value|
      if key =~ /^content-type$/i
        return !!(value =~ /application\/json/i)
      end
    end

    false
  end

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
