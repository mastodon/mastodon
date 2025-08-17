# frozen_string_literal: true

class Disputes::AppealsController < Disputes::BaseController
  before_action :set_strike

  def create
    authorize @strike, :appeal?

    @appeal = AppealService.new.call(@strike, appeal_params[:text])

    redirect_to disputes_strike_path(@strike), notice: I18n.t('disputes.strikes.appealed_msg')
  rescue ActiveRecord::RecordInvalid => e
    @appeal = e.record
    render 'disputes/strikes/show'
  end

  private

  def set_strike
    @strike = current_account.strikes.find(params[:strike_id])
  end

  def appeal_params
    params.expect(appeal: [:text])
  end
end
