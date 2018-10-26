# frozen_string_literal: true

class Settings::BaseController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_pack
  before_action :set_body_classes

  def set_pack
    use_pack 'settings'
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end
