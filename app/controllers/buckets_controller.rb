class BucketsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :record

  before_filter :load_bucket, except: :create

  def create
    bucket = Bucket.create(owner_token: owner_token)

    redirect_to bucket_path(bucket.token)
  end

  def show
    @requests = @bucket.requests.page(params[:page]).per 10
  end

  def last
    if last_request = @bucket.last_request
      render json: { body:        last_request.body,
                     headers:     last_request.headers,
                     created_at:  last_request.created_at }
    else
      redirect_to bucket_path(@bucket.token), alert: 'Please submit a request first'
    end
  end

  def last_response
    if last_response = @bucket.last_response
      render json: { status:      last_response.status,
                     body:        last_response.body,
                     headers:     last_response.headers,
                     created_at:  last_response.created_at }
    else
      redirect_to bucket_path(@bucket.token), alert: 'Please submit a request first'
    end
  end

  def response_builder
    @bucket.update_attribute :response_builder, params[:response_builder]

    redirect_to bucket_path(@bucket.token)
  end

  def record
    recorded_request  = @bucket.record_request(request)
    recorded_response = @bucket.build_response(recorded_request)

    response.headers.merge! recorded_response.headers.to_h

    render text: recorded_response.body_to_s, status: recorded_response.status
  end

  private

  def load_bucket
    @bucket = Bucket.where(token: params[:token]).first
  end

  def error_response
    { error: 'You have not submitted a request yet' }
  end
end
