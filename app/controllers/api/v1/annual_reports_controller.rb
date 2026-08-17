# frozen_string_literal: true

class Api::V1::AnnualReportsController < Api::BaseController
  include AsyncRefreshesConcern

  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, except: [:read, :generate]
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:read, :generate]
  before_action :require_user!
  before_action :set_annual_report, only: [:show, :read]

  def index
    with_read_replica do
      @presenter = AnnualReportsPresenter.new(GeneratedAnnualReport.where(account_id: current_account.id).pending)
      @relationships = StatusRelationshipsPresenter.new(@presenter.statuses, current_account.id)
    end

    render json: @presenter,
           serializer: REST::AnnualReportsSerializer,
           relationships: @relationships
  end

  def show
    with_read_replica do
      @presenter = AnnualReportsPresenter.new([@annual_report])
      @relationships = StatusRelationshipsPresenter.new(@presenter.statuses, current_account.id)
    end

    render json: @presenter,
           serializer: REST::AnnualReportsSerializer,
           relationships: @relationships
  end

  def state
    render json: { state: report_state }
  end

  def generate
    return render_empty unless year == AnnualReport.current_campaign
    return render_empty if GeneratedAnnualReport.exists?(account_id: current_account.id, year: year)

    async_refresh = AsyncRefresh.new(refresh_key)

    if async_refresh.running?
      add_async_refresh_header(async_refresh, retry_seconds: 2)
      return head 202
    end

    add_async_refresh_header(AsyncRefresh.create(refresh_key), retry_seconds: 2)

    GenerateAnnualReportWorker.perform_async(current_account.id, year)

    head 202
  end

  def read
    @annual_report.view!
    render_empty
  end

  private

  def report_state
    AnnualReport.new(current_account, year).state do |async_refresh|
      add_async_refresh_header(async_refresh, retry_seconds: 2)
    end
  end

  def refresh_key
    "wrapstodon:#{current_account.id}:#{year}"
  end

  def year
    params[:id]&.to_i
  end

  def set_annual_report
    @annual_report = GeneratedAnnualReport.find_by!(account_id: current_account.id, year: year)
  end
end
