class LogsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  http_basic_authenticate_with name: ENV['WHOWASHERE_USER'],
                               password: ENV['WHOWASHERE_PASSWORD'],
                               only: :create

  def create
    Rails.logger.warn "log(#{request.body.read.inspect})"
    head :ok
  end
end
