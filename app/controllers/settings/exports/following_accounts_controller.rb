# frozen_string_literal: true

module Settings
  module Exports
    class FollowingAccountsController < BaseController
      include Settings::ExportControllerConcern

      def index
        send_export_file
      end

      private

      def export_data
        @export.to_following_accounts_csv
      end
    end
  end
end
