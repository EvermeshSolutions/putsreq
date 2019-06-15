class RequestsController < ApplicationController
  def index
    bucket = Bucket.find_by(token: params[:token])

    requests = bucket.requests
    requests = requests.gt(id: params[:last_request_id]) if params[:last_request_id].present?
    requests = requests.limit(25).order(:id.asc)
    requests = requests.map(&:attributes)

    render json: JSON.generate(requests)
  end

  def show
    request = Request.find(params[:id])

    respond_to do |format|
      format.html { render plain: request.body }
      format.json { render json: JSON.pretty_generate(request.attributes) }
    end
  end
end