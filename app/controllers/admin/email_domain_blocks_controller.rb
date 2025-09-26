# frozen_string_literal: true

module Admin
  class EmailDomainBlocksController < BaseController
    def index
      authorize :email_domain_block, :index?

      @email_domain_blocks = EmailDomainBlock.parents.includes(:children).order(id: :desc).page(params[:page])
      @form                = Form::EmailDomainBlockBatch.new
    end

    def batch
      authorize :email_domain_block, :index?

      @form = Form::EmailDomainBlockBatch.new(form_email_domain_block_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.email_domain_blocks.no_email_domain_block_selected')
    rescue Mastodon::NotPermittedError
      flash[:alert] = I18n.t('admin.email_domain_blocks.not_permitted')
    ensure
      redirect_to admin_email_domain_blocks_path
    end

    def new
      authorize :email_domain_block, :create?
      @email_domain_block = EmailDomainBlock.new(domain: params[:_domain])
    end

    def create
      authorize :email_domain_block, :create?

      @email_domain_block = EmailDomainBlock.new(resource_params)

      if action_from_button == 'save'
        process_email_domain_block

        redirect_to admin_email_domain_blocks_path, notice: I18n.t('admin.email_domain_blocks.created_msg')
      else
        set_resolved_records
        render :new
      end
    rescue ActiveRecord::RecordInvalid
      set_resolved_records
      render :new
    end

    private

    def process_email_domain_block
      EmailDomainBlock.transaction do
        @email_domain_block.save!
        log_action :create, @email_domain_block
        save_other_domains
      end
    end

    def save_other_domains
      other_domains_from_block.each do |domain|
        next if EmailDomainBlock.exists?(domain: domain)

        log_action :create, block_child_domain(domain)
      end
    end

    def block_child_domain(domain)
      EmailDomainBlock.create!(
        allow_with_approval: @email_domain_block.allow_with_approval,
        domain: domain,
        parent: @email_domain_block
      )
    end

    def other_domains_from_block
      @email_domain_block
        .other_domains
        .to_a
        .uniq
    end

    def set_resolved_records
      @resolved_records = DomainResource.new(@email_domain_block.domain).mx
    end

    def resource_params
      params
        .expect(email_domain_block: [:domain, :allow_with_approval, other_domains: []])
    end

    def form_email_domain_block_batch_params
      params
        .expect(form_email_domain_block_batch: [email_domain_block_ids: []])
    end

    def action_from_button
      if params[:delete]
        'delete'
      elsif params[:save]
        'save'
      end
    end
  end
end
