# frozen_string_literal: true

module Admin
  class DomainBlocksController < BaseController
    before_action :set_domain_block, only: [:destroy, :edit, :update]
    before_action :authorize_domain_block_create, only: [:batch, :new, :create]
    with_options only: :create do
      before_action :populate_domain_block_from_params
      before_action :prevent_downgrade
    end

    PERMITTED_PARAMS = %i(
      domain
      obfuscate
      private_comment
      public_comment
      reject_media
      reject_reports
      severity
    ).freeze

    PERMITTED_UPDATE_PARAMS = PERMITTED_PARAMS.without(:domain).freeze

    def batch
      @form = Form::DomainBlockBatch.new(form_domain_block_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.domain_blocks.no_domain_block_selected')
    rescue Mastodon::NotPermittedError
      flash[:alert] = I18n.t('admin.domain_blocks.not_permitted')
    else
      flash[:notice] = I18n.t('admin.domain_blocks.created_msg')
    ensure
      redirect_to admin_instances_path(limited: '1')
    end

    def new
      @domain_block = DomainBlock.new(domain: params[:_domain])
    end

    def edit
      authorize :domain_block, :update?
    end

    def create
      # Allow transparently upgrading a domain block
      if existing_domain_block.present? && existing_domain_block.domain == TagManager.instance.normalize_domain(@domain_block.domain.strip)
        @domain_block = existing_domain_block
        @domain_block.assign_attributes(resource_params)
      end

      # Require explicit confirmation when suspending
      return render :confirm_suspension if requires_confirmation?

      if @domain_block.save
        DomainBlockWorker.perform_async(@domain_block.id)
        log_action :create, @domain_block
        redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.created_msg')
      else
        render :new
      end
    end

    def update
      authorize :domain_block, :update?

      @domain_block.assign_attributes(update_params)

      # Require explicit confirmation when suspending
      return render :confirm_suspension if requires_confirmation?

      if @domain_block.save
        DomainBlockWorker.perform_async(@domain_block.id, @domain_block.severity_previously_changed?)
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

    def authorize_domain_block_create
      authorize :domain_block, :create?
    end

    def populate_domain_block_from_params
      @domain_block = DomainBlock.new(resource_params)
    end

    def prevent_downgrade
      # Disallow accidental downgrade of an existing domain block record
      if existing_domain_block.present? && !@domain_block.stricter_than?(existing_domain_block)
        @domain_block.validate
        flash.now[:alert] = I18n.t('admin.domain_blocks.existing_domain_block_html', name: existing_domain_block.domain, unblock_url: admin_domain_block_path(existing_domain_block)).html_safe
        @domain_block.errors.delete(:domain)
        render :new
      end
    end

    def existing_domain_block
      @existing_domain_block ||= DomainBlock.rule_for(resource_params[:domain]) if resource_params[:domain].present?
    end

    def set_domain_block
      @domain_block = DomainBlock.find(params[:id])
    end

    def update_params
      params
        .require(:domain_block)
        .slice(*PERMITTED_UPDATE_PARAMS)
        .permit(*PERMITTED_UPDATE_PARAMS)
    end

    def resource_params
      params
        .require(:domain_block)
        .slice(*PERMITTED_PARAMS)
        .permit(*PERMITTED_PARAMS)
    end

    def form_domain_block_batch_params
      params
        .expect(
          form_domain_block_batch: [
            domain_blocks_attributes: [[:enabled, :domain, :severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate]],
          ]
        )
    end

    def action_from_button
      'save' if params[:save]
    end

    def requires_confirmation?
      @domain_block.valid? && (@domain_block.new_record? || @domain_block.severity_changed?) && @domain_block.suspend? && !params[:confirm]
    end
  end
end
