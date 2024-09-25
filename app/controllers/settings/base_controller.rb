# frozen_string_literal: true

class Settings::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_cache_headers

  private

  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end

  def require_not_suspended!
    forbidden if current_account.unavailable?
  end
end
