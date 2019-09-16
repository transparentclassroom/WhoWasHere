class SessionsController < ApplicationController
  skip_before_action :verify_authenticated, only: [:create]
  def create
    Admin.authenticate(auth_hash: auth_hash, session: session)
    redirect_to "/"
  end

  def destroy
    Admin.logout(session: session)
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end
end
