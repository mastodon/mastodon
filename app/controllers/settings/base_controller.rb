# frozen_string_literal: true

class Settings::BaseController < ApplicationController
  before_action :set_body_classes
  before_action :set_cache_headers

  private

  def set_body_classes
    @body_classes = 'admin'
  end

  def set_cache_headers
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
  end
end
