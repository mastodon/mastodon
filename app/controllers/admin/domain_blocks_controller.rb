# frozen_string_literal: true

module Admin
  class DomainBlocksController < BaseController
    def index
      @blocks = DomainBlock.page(params[:page])
    end

    def new
      @domain_block = DomainBlock.new
    end

    def create
      @domain_block = DomainBlock.new(resource_params)

      if @domain_block.save
        DomainBlockWorker.perform_async(@domain_block.id)
        redirect_to admin_domain_blocks_path, notice: I18n.t('admin.domain_blocks.created_msg')
      else
        render :new
      end
    end

    def show
      @domain_block = DomainBlock.find(params[:id])
    end

    def destroy
      @domain_block = DomainBlock.find(params[:id])
      UnblockDomainService.new.call(@domain_block, retroactive_unblock?)
      redirect_to admin_domain_blocks_path, notice: I18n.t('admin.domain_blocks.destroyed_msg')
    end

    private

    def resource_params
      params.require(:domain_block).permit(:domain, :severity, :reject_media, :retroactive)
    end

    def retroactive_unblock?
      resource_params[:retroactive] == '1'
    end
  end
end
