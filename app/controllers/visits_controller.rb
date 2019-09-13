class VisitsController < ApplicationController
  def index
    @visits = Visit
    @visits = Visit.order('id desc').page params[:page]
  end
end
