class SparklinesController < ApplicationController
  def index
    render json: Visit.sparkline_by_user(params[:school_id], params[:user_ids])
  end
end
