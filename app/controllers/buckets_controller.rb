class BucketsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :record

  before_filter :check_ownership!, only: %i[clear destroy update]

  def create
    new_bucket = { owner_token: owner_token }
    new_bucket[:user_id] = current_user.id if user_signed_in?

    bucket = Bucket.create(new_bucket)

    redirect_to bucket_path(bucket.token)
  end

  def fork
    forked_bucket = Bucket.create(owner_token:       owner_token,
                                  response_builder:  bucket.response_builder,
                                  name:              "Copy of #{bucket.name}",
                                  fork:              bucket)

    redirect_to bucket_path(forked_bucket.token)
  end

  def clear
    bucket.clear_history

    redirect_to bucket_path(bucket.token)
  end

  def destroy
    bucket.destroy

    redirect_to root_path
  end

  def show
    @requests = bucket.requests.page(params[:page]).per 5
  end

  def update
    update_bucket = bucket_params
    update_bucket[:user_id] = current_user.id if user_signed_in?

    bucket.update_attributes update_bucket

    redirect_to bucket_path(bucket.token)
  end

  def last
    if last_request = bucket.last_request
      response.headers.merge! Bucket.forwardable_headers(last_request.headers)

      render text: last_request.body

      return
    end

    render_request_not_found
  end

  def last_response
    if last_response = bucket.last_response
      response.headers.merge! Bucket.forwardable_headers(last_response.headers)

      render text: last_response.body_as_string

      return
    end

    render_request_not_found
  end

  def record
    result = RecordRequest.call(bucket: bucket, rack_request: request)
    recorded_response = result.response

    response.headers.merge! recorded_response.headers.to_h

    notify_count

    render text: recorded_response.body_as_string, status: recorded_response.status
  end

  private

  def notify_count
    return unless ENV['PUSHER_SECRET'] || ENV['PUSHER_APP_ID']

    Pusher.url = "http://3466d56fe2ef1fdd2943:#{ENV['PUSHER_SECRET']}@api.pusherapp.com/apps/#{ENV['PUSHER_APP_ID']}"

    Pusher["channel_#{bucket.token}"].trigger 'update_count', bucket.requests_count
  end

  def render_request_not_found
    respond_to do |format|
      format.html { redirect_to bucket_path(bucket.token), alert: 'Please submit a request first' }
      format.json { render nothing: true, status: 404 }
    end
  end

  def bucket_params
    params.require(:bucket).permit(:response_builder, :name)
  end
end
