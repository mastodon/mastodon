# frozen_string_literal: true

require 'csv'

module Admin
  class ExportDomainBlocksController < BaseController
    include AdminExportControllerConcern

    before_action :set_dummy_import!, only: [:new]

    def new
      authorize :domain_block, :create?
    end

    def export
      authorize :instance, :index?
      send_export_file
    end

    def import
      authorize :domain_block, :create?

      @import = Admin::Import.new(import_params)
      return render :new unless @import.validate

      parse_import_data!(export_headers)

      @global_private_comment = I18n.t('admin.export_domain_blocks.import.private_comment_template', source: @import.data_file_name, date: I18n.l(Time.now.utc))

      @form = Form::DomainBlockBatch.new
      @domain_blocks = @data.take(Admin::Import::ROWS_PROCESSING_LIMIT).filter_map do |row|
        domain = row['#domain'].strip
        next if DomainBlock.rule_for(domain).present?

        domain_block = DomainBlock.new(domain: domain,
                                       severity: row['#severity'].strip,
                                       reject_media: row['#reject_media'].strip,
                                       reject_reports: row['#reject_reports'].strip,
                                       private_comment: @global_private_comment,
                                       public_comment: row['#public_comment']&.strip,
                                       obfuscate: row['#obfuscate'].strip)

        domain_block if domain_block.valid?
      end

      @warning_domains = Instance.where(domain: @domain_blocks.map(&:domain)).where('EXISTS (SELECT 1 FROM follows JOIN accounts ON follows.account_id = accounts.id OR follows.target_account_id = accounts.id WHERE accounts.domain = instances.domain)').pluck(:domain)
    rescue ActionController::ParameterMissing
      flash.now[:alert] = I18n.t('admin.export_domain_blocks.no_file')
      set_dummy_import!
      render :new
    end

    private

    def export_filename
      'domain_blocks.csv'
    end

    def export_headers
      %w(#domain #severity #reject_media #reject_reports #public_comment #obfuscate)
    end

    def export_data
      CSV.generate(headers: export_headers, write_headers: true) do |content|
        DomainBlock.with_limitations.each do |instance|
          content << [instance.domain, instance.severity, instance.reject_media, instance.reject_reports, instance.public_comment, instance.obfuscate]
        end
      end
    end
  end
end
