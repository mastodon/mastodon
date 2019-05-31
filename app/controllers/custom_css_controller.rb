# frozen_string_literal: true

class CustomCssController < ApplicationController
  skip_before_action :check_access_requirements
  before_action :set_cache_headers

  def show
    skip_session!
    render plain: Setting.custom_css || '', content_type: 'text/css'
  end
end
