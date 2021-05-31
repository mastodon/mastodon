# frozen_string_literal: true

class CustomCssController < ApplicationController
  skip_before_action :store_current_location
  skip_before_action :require_functional!
  skip_before_action :update_user_sign_in
  skip_before_action :set_session_activity

  skip_around_action :set_locale

  before_action :set_cache_headers

  def show
    expires_in 3.minutes, public: true
    request.session_options[:skip] = true
    render plain: Setting.custom_css || '', content_type: 'text/css'
  end
end
