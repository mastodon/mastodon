# frozen_string_literal: true

class CustomCssController < ApplicationController
  skip_before_action :store_current_location
  skip_before_action :require_functional!
  skip_before_action :update_user_sign_in
  skip_before_action :set_session_activity

  skip_around_action :set_locale

  before_action :set_cache_headers

  def show
    return site_setting unless user_signed_in?

    sha = Digest::SHA1.hexdigest("#{Setting.custom_css}\n#{current_user.setting_custom_css}")
    return site_setting unless params[:sha] = sha

    expires_in 3.minutes, public: true
    render plain: "#{Setting.custom_css}\n#{current_user.setting_custom_css}" || '', content_type: 'text/css'
  end

  def site_setting
    expires_in 3.minutes, public: true
    request.session_options[:skip] = true
    render plain: Setting.custom_css || '', content_type: 'text/css'
  end
end
