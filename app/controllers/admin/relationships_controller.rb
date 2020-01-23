# frozen_string_literal: true

module Admin
  class RelationshipsController < BaseController
    before_action :set_account

    PER_PAGE = 40

    def index
      authorize :account, :index?

      @accounts = RelationshipFilter.new(@account, filter_params).results.page(params[:page]).per(PER_PAGE)
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
