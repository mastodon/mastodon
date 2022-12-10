# frozen_string_literal: true

module Admin
  class DomainBlocksController < BaseController
    before_action :set_domain_block, only: [:show, :destroy, :edit, :update]

    def batch
      authorize :domain_block, :create?
      @form = Form::DomainBlockBatch.new(form_domain_block_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.domain_blocks.no_domain_block_selected')
    rescue Mastodon::NotPermittedError
      flash[:alert] = I18n.t('admin.domain_blocks.not_permitted')
    else
      redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.created_msg')
    end

    def new
      authorize :domain_block, :create?
      @domain_block = DomainBlock.new(domain: params[:_domain])
    end

    def edit
      authorize :domain_block, :create?
    end

    def create
      authorize :domain_block, :create?

      @domain_block = DomainBlock.new(resource_params)
      existing_domain_block = resource_params[:domain].present? ? DomainBlock.rule_for(resource_params[:domain]) : nil

      if existing_domain_block.present? && !@domain_block.stricter_than?(existing_domain_block)
        @domain_block.save
        flash.now[:alert] = I18n.t('admin.domain_blocks.existing_domain_block_html', name: existing_domain_block.domain, unblock_url: admin_domain_block_path(existing_domain_block)).html_safe # rubocop:disable Rails/OutputSafety
        @domain_block.errors.delete(:domain)
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

    def update
      authorize :domain_block, :update?

      @domain_block.update(update_params)

      severity_changed = @domain_block.severity_changed?

      if @domain_block.save
        DomainBlockWorker.perform_async(@domain_block.id, severity_changed)
        log_action :update, @domain_block
        redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.created_msg')
      else
        render :edit
      end
    end

    def destroy
      authorize @domain_block, :destroy?
      UnblockDomainService.new.call(@domain_block)
      log_action :destroy, @domain_block
      redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.destroyed_msg')
    end

    private

    def set_domain_block
      @domain_block = DomainBlock.find(params[:id])
    end

    def update_params
      params.require(:domain_block).permit(:severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
    end

    def resource_params
      params.require(:domain_block).permit(:domain, :severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
    end

    def form_domain_block_batch_params
      params.require(:form_domain_block_batch).permit(domain_blocks_attributes: [:enabled, :domain, :severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate])
    end

    def action_from_button
      if params[:save]
        'save'
      end
    end
  end
end
