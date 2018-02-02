# frozen_string_literal: true

module Admin
  class StatusesController < BaseController
    helper_method :current_params

    before_action :set_account
    before_action :set_status, only: [:update, :destroy]

    PER_PAGE = 20

    def index
      authorize :status, :index?

      @statuses = @account.statuses

      if params[:media]
        account_media_status_ids = @account.media_attachments.attached.reorder(nil).select(:status_id).distinct
        @statuses.merge!(Status.where(id: account_media_status_ids))
      end

      @statuses = @statuses.preload(:media_attachments, :mentions).page(params[:page]).per(PER_PAGE)
      @form     = Form::StatusBatch.new
    end

    def create
      authorize :status, :update?

      @form         = Form::StatusBatch.new(form_status_batch_params.merge(current_account: current_account))
      flash[:alert] = I18n.t('admin.statuses.failed_to_execute') unless @form.save

      redirect_to admin_account_statuses_path(@account.id, current_params)
    end

    def update
      authorize @status, :update?
      @status.update!(status_params)
      log_action :update, @status
      redirect_to admin_account_statuses_path(@account.id, current_params)
    end

    def destroy
      authorize @status, :destroy?
      RemovalWorker.perform_async(@status.id)
      log_action :destroy, @status
      render json: @status
    end

    private

    def status_params
      params.require(:status).permit(:sensitive)
    end

    def form_status_batch_params
      params.require(:form_status_batch).permit(:action, status_ids: [])
    end

    def set_status
      @status = @account.statuses.find(params[:id])
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
  end
end
