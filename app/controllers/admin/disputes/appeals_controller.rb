# frozen_string_literal: true

class Admin::Disputes::AppealsController < Admin::BaseController
  before_action :set_appeal

  def approve
    authorize @appeal, :approve?
    log_action :approve, @appeal
    ApproveAppealService.new.call(@appeal)
    redirect_to disputes_strike_path(@appeal.strike)
  end

  private

  def set_appeal
    @appeal = Appeal.find(params[:id])
  end
end
