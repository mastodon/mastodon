# frozen_string_literal: true

class Api::V1::AnnualReportsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index
  before_action :require_user!
  before_action :set_annual_report, except: :index

  def index
    with_read_replica do
      @presenter = AnnualReportsPresenter.new(GeneratedAnnualReport.where(account_id: current_account.id).pending)
      @relationships = StatusRelationshipsPresenter.new(@presenter.statuses, current_account.id)
    end

    render json: @presenter,
           serializer: REST::AnnualReportsSerializer,
           relationships: @relationships
  end

  def read
    @annual_report.view!
    render_empty
  end

  private

  def set_annual_report
    @annual_report = GeneratedAnnualReport.find_by!(account_id: current_account.id, year: params[:id])
  end
end
