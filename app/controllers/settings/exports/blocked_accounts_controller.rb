# frozen_string_literal: true

module Settings
  module Exports
    class BlockedAccountsController < BaseController
      private

      def export_accounts
        current_account.blocking
      end
    end
  end
end
