# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authorization
    include AccountableConcern

    layout 'admin'

    before_action :set_pack
    before_action :set_body_classes
    after_action :verify_authorized

    private

    def set_body_classes
      @body_classes = 'admin'
    end

    def set_pack
      use_pack 'admin'
    end

    def set_user
      @user = Account.find(params[:account_id]).user || raise(ActiveRecord::RecordNotFound)
    end
  end
end
