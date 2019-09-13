class LogsController < ApplicationController
  def create
    Rails.logger.warn "log(#{request.body.read.inspect})"
  end
end
