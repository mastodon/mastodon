# frozen_string_literal: true

module Settings
  module Exports
    class CustomFiltersController < BaseController
      include Settings::ExportControllerConcern

      def index
        send_export_file
      end

      private

      def export_data
        @export.to_custom_filters_json
      end
    end
  end
end
