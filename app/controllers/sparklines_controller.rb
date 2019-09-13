class SparklinesController < ApplicationController
  def index
    render json: Visit.sparkline_by_email(params[:school_id], params[:emails])
  end
end
