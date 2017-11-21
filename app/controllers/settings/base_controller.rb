# frozen_string_literal: true

class Settings::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_pack

  def set_pack
    use_pack 'settings'
  end
end
