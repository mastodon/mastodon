# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authorization
    include AccountableConcern

    layout 'admin'

    before_action :require_staff!
    before_action :set_pack

    def set_pack
      use_pack 'admin'
    end
  end
end
