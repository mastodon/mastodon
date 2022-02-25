# frozen_string_literal: true

class Admin::Disputes::AppealsController < Admin::BaseController
  before_action :set_appeal, except: :index

  def index
    authorize :appeal, :index?

    @appeals = filtered_appeals.page(params[:page])
  end

  def approve
    authorize @appeal, :approve?
    log_action :approve, @appeal
    ApproveAppealService.new.call(@appeal, current_account)
    redirect_to disputes_strike_path(@appeal.strike)
  end

  def reject
    authorize @appeal, :approve?
    log_action :reject, @appeal
    @appeal.reject!(current_account)
    UserMailer.appeal_rejected(@appeal.account.user, @appeal)
    redirect_to disputes_strike_path(@appeal.strike)
  end

  private

  def filtered_appeals
    Admin::AppealFilter.new(filter_params.with_defaults(status: 'pending')).results.includes(strike: :account)
  end

  def filter_params
    params.slice(:page, *Admin::AppealFilter::KEYS).permit(:page, *Admin::AppealFilter::KEYS)
  end

  def set_appeal
    @appeal = Appeal.find(params[:id])
  end
end
