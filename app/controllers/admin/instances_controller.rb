# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_domain_block, only: :show
    before_action :set_domain_allow, only: :show
    before_action :set_instance, only: :show

    def index
      authorize :instance, :index?

      @instances = ordered_instances
    end

    def show
      authorize :instance, :show?

      @following_count = Follow.where(account: Account.where(domain: params[:id])).count
      @followers_count = Follow.where(target_account: Account.where(domain: params[:id])).count
      @reports_count   = Report.where(target_account: Account.where(domain: params[:id])).count
      @blocks_count    = Block.where(target_account: Account.where(domain: params[:id])).count
      @available       = DeliveryFailureTracker.available?(Account.select(:shared_inbox_url).where(domain: params[:id]).first&.shared_inbox_url)
      @media_storage   = MediaAttachment.where(account: Account.where(domain: params[:id])).sum(:file_file_size)
      @private_comment = @domain_block&.private_comment
      @public_comment  = @domain_block&.public_comment
    end

    private

    def set_domain_block
      @domain_block = DomainBlock.rule_for(params[:id])
    end

    def set_domain_allow
      @domain_allow = DomainAllow.rule_for(params[:id])
    end

    def set_instance
      resource   = Account.by_domain_accounts.find_by(domain: params[:id])
      resource ||= @domain_block
      resource ||= @domain_allow

      if resource
        @instance = Instance.new(resource)
      else
        not_found
      end
    end

    def filtered_instances
      InstanceFilter.new(whitelist_mode? ? { allowed: true } : filter_params).results
    end

    def paginated_instances
      filtered_instances.page(params[:page])
    end

    helper_method :paginated_instances

    def ordered_instances
      paginated_instances.map { |resource| Instance.new(resource) }
    end

    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
