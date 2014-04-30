class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def owner_token
    cookies[:owner_token] ||= { value: SecureRandom.hex(24), expires: 1.year.from_now }
  end
end
