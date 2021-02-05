# frozen_string_literal: true

require 'csv'

module Admin
  class DomainBlocksController < BaseController
    before_action :set_domain_block, only: [:show, :destroy, :edit, :update]
    before_action :dummy_import, only: [:new, :create]
    ROWS_PROCESSING_LIMIT = 20_000

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

    def show
      authorize @domain_block, :show?
    end

    def destroy
      authorize @domain_block, :destroy?
      UnblockDomainService.new.call(@domain_block)
      log_action :destroy, @domain_block
      redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.destroyed_msg')
    end

    def export
      authorize :instance, :index?
      csv = CSV.generate do |content|
        content << %w(#domain #severity)
        DomainBlock.blocked_domains.each do |instance|
          content << [instance.domain, instance.severity]
        end
      end
      respond_to do |format|
        format.csv { send_data csv, filename: 'blocked_domains.csv' }
      end
    end

    def import
      authorize :domain_block, :create?
      @import = Admin::Import.new(import_params)
      parse_import_data!(%w(#domain #severity))

      @data.take(ROWS_PROCESSING_LIMIT).each do |row|
        domain = row['#domain'].strip
        next if DomainBlock.rule_for(domain).present?

        domain_block = DomainBlock.new(domain: domain, severity: row['#severity'].strip)
        if domain_block.save
          DomainBlockWorker.perform_async(domain_block.id)
          log_action :create, domain_block
        end
      end
      redirect_to admin_instances_path(limited: '1'), notice: I18n.t('admin.domain_blocks.created_msg')
    end

    private

    def set_domain_block
      @domain_block = DomainBlock.find(params[:id])
    end

    def dummy_import
      @import = Admin::Import.new
    end

    def update_params
      params.require(:domain_block).permit(:severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
    end

    def resource_params
      params.require(:domain_block).permit(:domain, :severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
    end

    def import_params
      params.require(:admin_import).permit(:data)
    end

    def parse_import_data!(default_headers)
      data = CSV.parse(import_data, headers: true)
      data = CSV.parse(import_data, headers: default_headers) unless data.headers&.first&.strip&.include?('#domain')
      @data = data.reject(&:blank?)
    end

    def import_data
      Paperclip.io_adapters.for(@import.data).read
    end
  end
end
