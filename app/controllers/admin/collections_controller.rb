# frozen_string_literal: true

module Admin
  class CollectionsController < BaseController
    before_action :set_account
    before_action :set_collection, only: :show
    before_action :set_collections, except: :show

    PER_PAGE = 20

    def index
      authorize [:admin, :collection], :index?
      @collection_batch_action = Admin::CollectionBatchAction.new
    end

    def show
      authorize @collection, :show?
    end

    def batch
      authorize [:admin, :collection], :index?

      @collection_batch_action = Admin::CollectionBatchAction.new(admin_collection_batch_action_params.merge(current_account: current_account, report_id: params[:report_id], type: 'report'))

      @collection_batch_action.save!
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.collections.no_collection_selected')
    ensure
      redirect_to after_create_redirect_path
    end

    private

    def after_create_redirect_path
      report_id = @collections_batch_action&.report_id || params[:report_id]

      if report_id.present?
        admin_report_path(report_id)
      else
        admin_account_collections_path(params[:account_id], params[:page])
      end
    end

    def admin_collection_batch_action_params
      params
        .expect(admin_collection_batch_action: [collection_ids: []])
    end

    def set_account
      @account = Account.find(params[:account_id])
    end

    def set_collection
      @collection = @account.collections.includes(accepted_collection_items: :account).find(params[:id])
    end

    def set_collections
      @collections = @account.collections.includes(accepted_collection_items: :account).page(params[:page]).per(PER_PAGE)
    end
  end
end
