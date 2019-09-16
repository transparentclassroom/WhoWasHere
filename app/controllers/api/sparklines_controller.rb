module Api
  class SparklinesController < ApiController
    def index
      render json: Visit.sparkline_by_user(params[:school_id], params[:ids])
    end
  end
end
