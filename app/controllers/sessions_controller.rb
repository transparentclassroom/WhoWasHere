class SessionsController < ApplicationController
  skip_before_action :verify_authenticated, only: [:create]
  def create
    Admin.authenticate(info: auth_hash.info, session: session)
    flash[:notice] = "Authentication successful"
    redirect_to "/"
  end

  def destroy
    flash[:notice] = "You have been logged out"
    Admin.logout(session: session)
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end
end
