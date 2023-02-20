# frozen_string_literal: true

module Admin
  class RelationshipsController < BaseController
    before_action :set_account

    PER_PAGE = 40

    def index
      authorize @account, :show?

      @accounts = RelationshipFilter.new(@account, filter_params).results.includes(:account_stat, user: %i(ips invite_request)).page(params[:page]).per(PER_PAGE)
      @form     = Form::AccountBatch.new
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def filter_params
      params.slice(*RelationshipFilter::KEYS).permit(*RelationshipFilter::KEYS)
    end
  end
end
