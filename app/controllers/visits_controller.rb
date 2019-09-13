class VisitsController < ApplicationController
  def index
    @visits = Visit
    @visits = @visits.where(user_id: params[:user_id]) if params[:user_id]
    @visits = @visits.where(school_id: params[:school_id]) if params[:school_id]
    @visits = @visits.order('id desc').page params[:page]
  end
end
