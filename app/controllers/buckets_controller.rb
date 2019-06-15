class BucketsController < ApplicationController
  include ActionController::Live

  skip_before_action :verify_authenticity_token, only: :record

  before_action :check_ownership!, only: %i[clear destroy update]

  def requests_count
    response.headers['Content-Type'] = 'text/event-stream'
    sse = SSE.new(response.stream, event: 'requests_count')
    begin
      sse.write(requests_count: bucket.requests.count)
    rescue ClientDisconnected
    ensure
      sse.close
    end
  end

  def create
    redirect_to bucket_path(bucket.token)
  end

  def fork
    fork = Bucket.create(
      owner_token: owner_token,
      response_builder: bucket.response_builder,
      name: "Copy of #{bucket.name}",
      fork: bucket
    )

    redirect_to bucket_path(fork.token)
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
    bucket.request = bucket.requests.page(params[:page]).per(1).first

    respond_to do |format|
      format.html { render }
      format.json { render json: bucket, serializer: BucketSerializer }
    end
  end

  def update
    update_bucket = bucket_params
    update_bucket[:user_id] = current_user.id if user_signed_in?

    bucket.update update_bucket

    redirect_to bucket_path(bucket.token)
  end

  def last
    return render_request_not_found unless last_request = bucket.last_request

    respond_to do |format|
      format.html { render plain: last_request.body }
      format.json { render json: JSON.pretty_generate(last_request.attributes) }
    end
  end

  def last_response
    return render_request_not_found unless last_response = bucket.last_response

    respond_to do |format|
      format.html { render plain: last_response.body }
      format.json { render json: JSON.pretty_generate(last_response.attributes) }
    end
  end

  def record
    result = RecordRequest.call(bucket: bucket, rack_request: request)
    recorded_response = result.response

    response.headers.merge! recorded_response.headers.to_h

    render plain: body_as_string(recorded_response),
           status: recorded_response.status
  end

  private

  def render_request_not_found
    respond_to do |format|
      format.html { redirect_to bucket_path(bucket.token), alert: 'Please submit a request first' }
      format.json { head :not_found }
    end
  end

  def bucket_params
    params.require(:bucket).permit(:response_builder, :name)
  end
end
