# frozen_string_literal: true

class Settings::BaseController < ApplicationController
  before_action :set_body_classes

  private

  def set_body_classes
    @body_classes = 'admin'
  end
end
