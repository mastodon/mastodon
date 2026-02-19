# frozen_string_literal: true

module Admin::ExportControllerConcern
  extend ActiveSupport::Concern

  private

  def send_export_file
    respond_to do |format|
      format.csv { send_data export_data, filename: export_filename }
    end
  end

  def export_data
    raise 'Override in controller'
  end

  def export_filename
    raise 'Override in controller'
  end

  def set_dummy_import!
    @import = Admin::Import.new
  end

  def import_params
    params.expect(admin_import: [:data])
  end
end
