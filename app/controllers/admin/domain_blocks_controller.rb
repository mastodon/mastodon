# frozen_string_literal: true

module Admin
  class DomainBlocksController < BaseController
    before_action :set_domain_block, only: [:show, :destroy]

    def new
      authorize :domain_block, :create?
      @domain_block = DomainBlock.new(domain: params[:_domain])
    end

    def create
      authorize :domain_block, :create?

      @domain_block = DomainBlock.new(resource_params)
      existing_domain_block = resource_params[:domain].present? ? DomainBlock.find_by(domain: resource_params[:domain]) : nil

      if existing_domain_block.present? && !@domain_block.stricter_than?(existing_domain_block)
        @domain_block.save
        flash[:alert] = I18n.t('admin.domain_blocks.existing_domain_block_html', name: existing_domain_block.domain, unblock_url: admin_domain_block_path(existing_domain_block)).html_safe # rubocop:disable Rails/OutputSafety
        @domain_block.errors[:domain].clear
        render :new
      else
        if existing_domain_block.present?
          @domain_block = existing_domain_block
          @domain_block.update(resource_params)
        end
        if @domain_block.save
          DomainBlockWorker.perform_async(@domain_block.id)
          log_action :create, @domain_block
          redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.created_msg')
        else
          render :new
        end
      end
    end

    def show
      authorize @domain_block, :show?
    end

    def destroy
      authorize @domain_block, :destroy?
      UnblockDomainService.new.call(@domain_block, retroactive_unblock?)
      log_action :destroy, @domain_block
      redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.destroyed_msg')
    end

    private

    def set_domain_block
      @domain_block = DomainBlock.find(params[:id])
    end

    def resource_params
      params.require(:domain_block).permit(:domain, :severity, :reject_media, :reject_reports, :retroactive)
    end

    def retroactive_unblock?
      ActiveRecord::Type.lookup(:boolean).cast(resource_params[:retroactive])
    end
  end
end
