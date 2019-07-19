# frozen_string_literal: true

class CustomCssController < ApplicationController
  skip_before_action :store_current_location

  before_action :set_cache_headers

  def show
    expires_in 3.minutes, public: true
    render plain: Setting.custom_css || '', content_type: 'text/css'
  end
end
