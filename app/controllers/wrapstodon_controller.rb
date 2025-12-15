# frozen_string_literal: true

class WrapstodonController < ApplicationController
  include WebAppControllerConcern
  include Authorization
  include AccountOwnedConcern

  vary_by 'Accept, Accept-Language, Cookie'

  before_action :set_generated_annual_report

  skip_before_action :require_functional!, only: :show, unless: :limited_federation_mode?

  def show
    expires_in 10.minutes, public: true if current_account.nil?
  end

  private

  def set_generated_annual_report
    @generated_annual_report = GeneratedAnnualReport.find_by!(account: @account, year: params[:year], share_key: params[:share_key])
  end
end
