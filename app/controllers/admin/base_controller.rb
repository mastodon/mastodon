# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    include Authorization
    include AccountableConcern

    layout 'admin'

    before_action :set_referrer_policy_header

    after_action :verify_authorized

    private

    def set_referrer_policy_header
      response.headers['Referrer-Policy'] = 'same-origin'
    end

    def set_user
      @user = Account.find(params[:account_id]).user || raise(ActiveRecord::RecordNotFound)
    end
  end
end
