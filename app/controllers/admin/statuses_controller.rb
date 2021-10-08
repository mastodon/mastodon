# frozen_string_literal: true

module Admin
  class StatusesController < BaseController
    helper_method :current_params

    before_action :set_account

    PER_PAGE = 20

    def index
      authorize :status, :index?

      @statuses = @account.statuses.where(visibility: [:public, :unlisted])

      if params[:media]
        @statuses.merge!(Status.joins(:media_attachments).merge(@account.media_attachments.reorder(nil)).group(:id))
      end

      @statuses = @statuses.preload(:media_attachments, :mentions).page(params[:page]).per(PER_PAGE)
      @form     = Form::StatusBatch.new
    end

    def show
      authorize :status, :index?

      @statuses = @account.statuses.where(id: params[:id])
      authorize @statuses.first, :show?

      @form = Form::StatusBatch.new
    end

    def create
      authorize :status, :update?

      @form         = Form::StatusBatch.new(form_status_batch_params.merge(current_account: current_account, action: action_from_button))
      flash[:alert] = I18n.t('admin.statuses.failed_to_execute') unless @form.save

      redirect_to admin_account_statuses_path(@account.id, current_params)
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.statuses.no_status_selected')

      redirect_to admin_account_statuses_path(@account.id, current_params)
    end

    private

    def form_status_batch_params
      params.require(:form_status_batch).permit(:action, status_ids: [])
    end

    def set_account
      @account = Account.find(params[:account_id])
    end

    def current_params
      page = (params[:page] || 1).to_i

      {
        media: params[:media],
        page: page > 1 && page,
      }.select { |_, value| value.present? }
    end

    def action_from_button
      if params[:nsfw_on]
        'nsfw_on'
      elsif params[:nsfw_off]
        'nsfw_off'
      elsif params[:delete]
        'delete'
      end
    end
  end
end
