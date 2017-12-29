class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :bucket, :owner?, :body_as_string, :headers_as_string

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def body_as_string(req_or_res)
    body = req_or_res.body

    if body_json?(req_or_res) && body.is_a?(String)
      # See https://github.com/phstc/putsreq/issues/31#issuecomment-271681249
      return JSON.pretty_generate(JSON.parse(body))
    end

    if body.is_a?(Hash)
      # For responses body can be a hash
      # body.to_h because body can be a BSON::Document
      # which for some reason does format well with
      # pretty_generate
      return JSON.pretty_generate(body.to_h)
    end

    if body.is_a?(Array)
      # see https://github.com/phstc/putsreq/issues/33
      return JSON.pretty_generate(body.to_a)
    end

    body.to_s
  rescue
    body.to_s
  end

  def headers_as_string(req_or_res)
    JSON.pretty_generate(req_or_res.headers.to_h)
  end

  def body_json?(req_or_res)
    req_or_res.headers.to_h.each do |key, value|
      return !!(value =~ /application\/json/i) if key =~ /^content-type$/i
    end

    false
  end

  def check_ownership!
    return if owner?(bucket)

    redirect_to bucket_path(bucket.token), alert: 'Only the bucket owner can perform this operation'
  end

  def owner?(bucket)
    return true unless bucket.user

    owner_token == bucket.owner_token || (user_signed_in? && bucket.user == current_user)
  end

  def owner_token
    cookies[:owner_token] ||= { value: SecureRandom.hex(24), expires: 1.year.from_now }
  end

  def bucket
    @_bucket ||= CreateOrRetrieveBucket.call!(
      token: params[:token],
      owner_token: owner_token,
      user_id: (current_user.id if user_signed_in?)
    ).bucket
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation, :remember_me])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:name, :email, :password, :remember_me])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation, :current_password])
  end
end
