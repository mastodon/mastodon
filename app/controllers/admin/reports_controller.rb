# frozen_string_literal: true

class Admin::ReportsController < ApplicationController
  before_action :require_admin!
  before_action :set_report, except: [:index]

  layout 'admin'

  def index
    @reports = Report.includes(:account, :target_account).order('id desc').paginate(page: params[:page], per_page: 40)
    @reports = params[:action_taken].present? ? @reports.resolved : @reports.unresolved
  end

  def show
    @statuses = Status.where(id: @report.status_ids)
  end

  def resolve
    @report.update(action_taken: true)
    redirect_to admin_report_path(@report)
  end

  def suspend
    Admin::SuspensionWorker.perform_async(@report.target_account.id)
    @report.update(action_taken: true)
    redirect_to admin_report_path(@report)
  end

  def silence
    @report.target_account.update(silenced: true)
    @report.update(action_taken: true)
    redirect_to admin_report_path(@report)
  end

  def remove
    RemovalWorker.perform_async(params[:status_id])
    redirect_to admin_report_path(@report)
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end
end
