# frozen_string_literal: true

class CustomCssController < ApplicationController
  before_action :set_cache_headers

  def show
    skip_session!
    render plain: Setting.custom_css || '', content_type: 'text/css'
  end
end
