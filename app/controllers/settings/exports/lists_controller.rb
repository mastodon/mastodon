# frozen_string_literal: true

module Settings
  module Exports
    class ListsController < BaseController
      include ExportControllerConcern

      def index
        send_export_file
      end

      private

      def export_data
        @export.to_lists_csv
      end
    end
  end
end
