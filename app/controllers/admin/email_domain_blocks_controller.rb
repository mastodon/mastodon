# frozen_string_literal: true

module Admin
  class EmailDomainBlocksController < BaseController
    def index
      authorize :email_domain_block, :index?

      @email_domain_blocks = EmailDomainBlock.where(parent_id: nil).includes(:children).order(id: :desc).page(params[:page])
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
        EmailDomainBlock.transaction do
          @email_domain_block.save!
          log_action :create, @email_domain_block

          (@email_domain_block.other_domains || []).uniq.each do |domain|
            next if EmailDomainBlock.exists?(domain: domain)

            other_email_domain_block = EmailDomainBlock.create!(domain: domain, allow_with_approval: @email_domain_block.allow_with_approval, parent: @email_domain_block)
            log_action :create, other_email_domain_block
          end
        end

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

    def set_resolved_records
      Resolv::DNS.open do |dns|
        dns.timeouts = 5
        @resolved_records = dns.getresources(@email_domain_block.domain, Resolv::DNS::Resource::IN::MX).to_a
      end
    end

    def resource_params
      params.require(:email_domain_block).permit(:domain, :allow_with_approval, other_domains: [])
    end

    def form_email_domain_block_batch_params
      params.require(:form_email_domain_block_batch).permit(email_domain_block_ids: [])
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
