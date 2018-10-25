# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authorization
    include AccountableConcern

    layout 'admin'

    before_action :require_staff!
    before_action :set_body_classes

    private

    def set_body_classes
      @body_classes = 'admin'
    end
  end
end
