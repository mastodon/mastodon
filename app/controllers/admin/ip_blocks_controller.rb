# frozen_string_literal: true

module Admin
  class IpBlocksController < BaseController
    def index
      authorize :ip_block, :index?

      @ip_blocks = IpBlock.order(ip: :asc).page(params[:page])
      @form      = Form::IpBlockBatch.new
    end

    def new
      authorize :ip_block, :create?

      @ip_block = IpBlock.new(ip: '', severity: :no_access, expires_in: 1.year)
    end

    def create
      authorize :ip_block, :create?

      @ip_block = IpBlock.new(resource_params)

      if @ip_block.save
        log_action :create, @ip_block
        redirect_to admin_ip_blocks_path, notice: I18n.t('admin.ip_blocks.created_msg')
      else
        render :new
      end
    end

    def batch
      authorize :ip_block, :index?

      @form = Form::IpBlockBatch.new(form_ip_block_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.ip_blocks.no_ip_block_selected')
    rescue Mastodon::NotPermittedError
      flash[:alert] = I18n.t('admin.custom_emojis.not_permitted')
    ensure
      redirect_to admin_ip_blocks_path
    end

    private

    def resource_params
      params
        .expect(ip_block: [:ip, :severity, :comment, :expires_in])
    end

    def action_from_button
      'delete' if params[:delete]
    end

    def form_ip_block_batch_params
      params
        .expect(form_ip_block_batch: [ip_block_ids: []])
    end
  end
end
