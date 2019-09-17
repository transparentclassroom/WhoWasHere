class ApplicationController < ActionController::Base
  before_action :verify_authenticated

  def verify_authenticated
    redirect_to "/auth/google_oauth2" unless session[:current_user_email]
  end

  helper_method def current_admin
    @current_admin ||= Admin.from_session(session: session)
  end
end
