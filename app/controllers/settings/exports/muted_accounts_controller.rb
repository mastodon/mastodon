# frozen_string_literal: true

module Settings
  module Exports
    class MutedAccountsController < BaseController
      private

      def export_accounts
        current_account.muting
      end
    end
  end
end
