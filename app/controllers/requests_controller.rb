class RequestsController < ApplicationController
  def show
    request = Request.find(params[:id])

    respond_to do |format|
      format.html { render plain: request.body }
      format.json { render json: JSON.pretty_generate(request.attributes) }
    end
  end
end
