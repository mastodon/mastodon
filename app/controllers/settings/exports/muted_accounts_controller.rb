# frozen_string_literal: true

module Settings
  module Exports
    class MutedAccountsController < BaseController
      private

      def export_data
        @export.to_muted_accounts_csv
      end
    end
  end
end
