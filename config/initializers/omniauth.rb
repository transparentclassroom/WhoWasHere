Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_OAUTH2_APP_ID"], ENV["GOOGLE_OAUTH2_APP_SECRET"], {prompt: :select_account}
end
OmniAuth.config.allowed_request_methods = %i[get]
