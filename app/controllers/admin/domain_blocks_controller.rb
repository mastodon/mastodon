# frozen_string_literal: true

module Admin
  class DomainBlocksController < BaseController
    before_action :set_domain_block, only: [:show, :destroy]

    def index
      authorize :domain_block, :index?
      @domain_blocks = DomainBlock.page(params[:page])
    end

    def new
      authorize :domain_block, :create?
      @domain_block = DomainBlock.new
    end

    def create
      authorize :domain_block, :create?

      @domain_block = DomainBlock.new(resource_params)

      if @domain_block.save
        DomainBlockWorker.perform_async(@domain_block.id)
        log_action :create, @domain_block
        redirect_to admin_domain_blocks_path, notice: I18n.t('admin.domain_blocks.created_msg')
      else
        render :new
      end
    end

    def show
      authorize @domain_block, :show?
    end

    def destroy
      authorize @domain_block, :destroy?
      UnblockDomainService.new.call(@domain_block, retroactive_unblock?)
      log_action :destroy, @domain_block
      redirect_to admin_domain_blocks_path, notice: I18n.t('admin.domain_blocks.destroyed_msg')
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
