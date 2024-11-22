# frozen_string_literal: true

require 'csv'

module Admin
  class ExportDomainBlocksController < BaseController
    include Admin::ExportControllerConcern

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

      @global_private_comment = I18n.t('admin.export_domain_blocks.import.private_comment_template', source: @import.data_file_name, date: I18n.l(Time.now.utc))

      @form = Form::DomainBlockBatch.new
      @domain_blocks = @import.csv_rows.filter_map do |row|
        domain = row['#domain'].strip
        next if DomainBlock.rule_for(domain).present?

        domain_block = DomainBlock.new(domain: domain,
                                       severity: row.fetch('#severity', :suspend),
                                       reject_media: row.fetch('#reject_media', false),
                                       reject_reports: row.fetch('#reject_reports', false),
                                       private_comment: @global_private_comment,
                                       public_comment: row['#public_comment'],
                                       obfuscate: row.fetch('#obfuscate', false))

        if domain_block.invalid?
          flash.now[:alert] = I18n.t('admin.export_domain_blocks.invalid_domain_block', error: domain_block.errors.full_messages.join(', '))
          next
        end

        domain_block
      rescue ArgumentError => e
        flash.now[:alert] = I18n.t('admin.export_domain_blocks.invalid_domain_block', error: e.message)
        next
      end

      @warning_domains = instances_from_imported_blocks.pluck(:domain)
    rescue ActionController::ParameterMissing
      flash.now[:alert] = I18n.t('admin.export_domain_blocks.no_file')
      set_dummy_import!
      render :new
    end

    private

    def instances_from_imported_blocks
      Instance.with_domain_follows(@domain_blocks.map(&:domain))
    end

    def export_filename
      'domain_blocks.csv'
    end

    def export_headers
      %w(#domain #severity #reject_media #reject_reports #public_comment #obfuscate)
    end

    def export_data
      CSV.generate(headers: export_headers, write_headers: true) do |content|
        DomainBlock.with_limitations.order(id: :asc).each do |instance|
          content << [instance.domain, instance.severity, instance.reject_media, instance.reject_reports, instance.public_comment, instance.obfuscate]
        end
      end
    end
  end
end
