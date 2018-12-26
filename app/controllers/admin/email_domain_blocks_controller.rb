# frozen_string_literal: true

module Admin
  class EmailDomainBlocksController < BaseController
    before_action :set_email_domain_block, only: [:show, :destroy]

    def index
      authorize :email_domain_block, :index?
      @email_domain_blocks = EmailDomainBlock.page(params[:page])
    end

    def new
      authorize :email_domain_block, :create?
      @email_domain_block = EmailDomainBlock.new
    end

    def create
      authorize :email_domain_block, :create?

      @email_domain_block = EmailDomainBlock.new(resource_params)

      if @email_domain_block.save
        log_action :create, @email_domain_block
        redirect_to admin_email_domain_blocks_path, notice: I18n.t('admin.email_domain_blocks.created_msg')
      else
        render :new
      end
    end

    def destroy
      authorize @email_domain_block, :destroy?
      @email_domain_block.destroy!
      log_action :destroy, @email_domain_block
      redirect_to admin_email_domain_blocks_path, notice: I18n.t('admin.email_domain_blocks.destroyed_msg')
    end

    private

    def set_email_domain_block
      @email_domain_block = EmailDomainBlock.find(params[:id])
    end

    def resource_params
      params.require(:email_domain_block).permit(:domain)
    end
  end
end
