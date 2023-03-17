class ApplicationController < ActionController::Base
  # ログアウト後本番環境でログイン画面に遷移しないため↓
  before_action :authenticate_user!, only: [:/]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :basic_auth

  private
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
    end
    def basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV["BASIC_USER"] && password == ENV["BASIC_PASSWORD"]
      end
    end
end
