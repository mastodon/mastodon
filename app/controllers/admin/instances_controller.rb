# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    def index
      authorize :instance, :index?
      @instances = ordered_instances
    end

    def resubscribe
      authorize :instance, :resubscribe?
      params.require(:by_domain)
      Pubsubhubbub::SubscribeWorker.push_bulk(subscribeable_accounts.pluck(:id))
      redirect_to admin_instances_path
    end

    private

    def filtered_instances
      InstanceFilter.new(filter_params).results
    end

    def paginated_instances
      filtered_instances.page(params[:page])
    end

    helper_method :paginated_instances

    def ordered_instances
      paginated_instances.map { |account| Instance.new(account) }
    end

    def subscribeable_accounts
      Account.remote.where(protocol: :ostatus).where(domain: params[:by_domain])
    end

    def filter_params
      params.permit(
        :domain_name
      )
    end
  end
end
