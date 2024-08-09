# frozen_string_literal: true

class Disputes::BaseController < ApplicationController
  include Authorization

  layout 'admin'

  skip_before_action :require_functional!

  before_action :authenticate_user!
  before_action :set_cache_headers

  private

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
