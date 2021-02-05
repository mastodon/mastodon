# frozen_string_literal: true

require 'csv'

class Admin::DomainAllowsController < Admin::BaseController
  include AdminExportControllerConcern
  before_action :set_domain_allow, only: [:destroy]
  ROWS_PROCESSING_LIMIT = 20_000

  def new
    authorize :domain_allow, :create?

    @domain_allow = DomainAllow.new(domain: params[:_domain])
  end

  def create
    authorize :domain_allow, :create?

    @domain_allow = DomainAllow.new(resource_params)

    if @domain_allow.save
      log_action :create, @domain_allow
      redirect_to admin_instances_path, notice: I18n.t('admin.domain_allows.created_msg')
    else
      render :new
    end
  end

  def destroy
    authorize @domain_allow, :destroy?
    UnallowDomainService.new.call(@domain_allow)
    redirect_to admin_instances_path, notice: I18n.t('admin.domain_allows.destroyed_msg')
  end

  def export
    authorize :instance, :index?
    send_export_file
  end

  def import
    authorize :domain_allow, :create?
    @import = Admin::Import.new(import_params)
    parse_import_data!(export_headers)

    @data.take(ROWS_PROCESSING_LIMIT).each do |row|
      domain = row['#domain'].strip
      next if DomainAllow.allowed?(domain)

      domain_allow = DomainAllow.new(domain: domain)
      log_action :create, domain_allow if domain_allow.save
    end
    redirect_to admin_instances_path, notice: I18n.t('admin.domain_allows.created_msg')
  end

  private

  def set_domain_allow
    @domain_allow = DomainAllow.find(params[:id])
  end

  def resource_params
    params.require(:domain_allow).permit(:domain)
  end

  def export_filename
    'domain_allows.csv'
  end

  def export_headers
    %w(#domain)
  end

  def export_data
    CSV.generate do |content|
      content << export_headers
      DomainAllow.allowed_domains.each do |instance|
        content << [instance.domain]
      end
    end
  end
end
