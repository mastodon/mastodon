# frozen_string_literal: true

module Settings::ExportControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :load_export

    skip_before_action :check_self_destruct!
    skip_before_action :require_functional!
  end

  private

  def load_export
    @export = Export.new(current_account)
  end

  def send_export_file
    respond_to do |format|
      format.csv { send_data export_data, filename: "#{controller_name}.csv" }
      format.json { send_data export_data, filename: "#{controller_name}.json" }
    end
  end

  def export_data
    raise 'Override in controller'
  end
end
