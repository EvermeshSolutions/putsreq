class BucketsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :record

  before_filter :check_ownership!, only: %i[clear destroy update]

  def create
    bucket = Bucket.create(owner_token: owner_token)

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
    bucket.requests.delete_all
    bucket.responses.delete_all

    redirect_to bucket_path(bucket.token)
  end

  def destroy
    bucket.destroy

    redirect_to root_path
  end

  def show
    @requests = bucket.requests.page(params[:page]).per 10
  end

  def update
    bucket.update_attributes bucket_params

    redirect_to bucket_path(bucket.token)
  end

  def last
    if last_request = bucket.last_request
      render json: { body:        last_request.body,
                     headers:     last_request.headers,
                     created_at:  last_request.created_at }
      return
    end

    render_request_not_found
  end

  def last_response
    if last_response = bucket.last_response
      render json: { status:      last_response.status,
                     body:        last_response.body,
                     headers:     last_response.headers,
                     created_at:  last_response.created_at }
      return
    end

    render_request_not_found
  end

  def requests_count
    render text: bucket.requests_count
  end

  def record
    recorded_request  = bucket.record_request(request)
    recorded_response = bucket.build_response(recorded_request)

    response.headers.merge! recorded_response.headers.to_h

    render text: recorded_response.body_to_s, status: recorded_response.status
  end

  private

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
