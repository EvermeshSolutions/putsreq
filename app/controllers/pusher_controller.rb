class PusherController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :auth

  def auth
    response = Pusher.authenticate(params[:channel_name], params[:socket_id], {
      user_id: current_user&.id || (session[:pusher_user_id] ||= BSON::ObjectId.new.to_s),
    })
    render json: response
  end
end
