# frozen_string_literal: true

class Admin::ReportsController < ApplicationController
  before_action :require_admin!

  layout 'admin'

  def index
    @reports = Report.includes(:account, :target_account).paginate(page: params[:page], per_page: 40)
    @reports = params[:action_taken].present? ? @reports.resolved : @reports.unresolved
  end

  def show
    @report   = Report.find(params[:id])
    @statuses = Status.where(id: @report.status_ids)
  end
end
