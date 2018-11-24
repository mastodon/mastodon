# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    def index
      authorize :instance, :index?

      @instances = ordered_instances
    end

    def show
      authorize :instance, :show?

      @instance        = Instance.new(Account.by_domain_accounts.find_by(domain: params[:id]) || DomainBlock.find_by!(domain: params[:id]))
      @following_count = Follow.where(account: Account.where(domain: params[:id])).count
      @followers_count = Follow.where(target_account: Account.where(domain: params[:id])).count
      @reports_count   = Report.where(target_account: Account.where(domain: params[:id])).count
      @blocks_count    = Block.where(target_account: Account.where(domain: params[:id])).count
      @available       = DeliveryFailureTracker.available?(Account.select(:shared_inbox_url).where(domain: params[:id]).first&.shared_inbox_url)
      @media_storage   = MediaAttachment.where(account: Account.where(domain: params[:id])).sum(:file_file_size)
      @domain_block    = DomainBlock.find_by(domain: params[:id])
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
      paginated_instances.map { |resource| Instance.new(resource) }
    end

    def filter_params
      params.permit(:limited)
    end
  end
end
