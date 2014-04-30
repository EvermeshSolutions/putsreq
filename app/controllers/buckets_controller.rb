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
    last_req = @bucket.last_req

    render json: { body:        last_req.body,
                   headers:     last_req.headers,
                   created_at:  last_req.created_at }
  end

  def last_response
    last_resp = @bucket.last_resp

    render json: { status:      last_resp.status,
                   body:        last_resp.body,
                   headers:     last_resp.headers,
                   created_at:  last_resp.created_at }
  end

  def response_builder
    @bucket.update_attribute :response_builder, params[:response_builder]

    redirect_to bucket_path(@bucket.token)
  end

  def record
    req  = @bucket.record_request(request)
    resp = @bucket.build_response(req)

    response.headers.merge! resp.headers.to_h
    render text: resp.body_to_s, status: resp.status
  end

  private

  def load_bucket
    @bucket = Bucket.where(token: params[:token]).first
  end
end
