# frozen_string_literal: true

module Settings
  module Exports
    class FollowingAccountsController < BaseController
      private

      def export_accounts
        current_account.following
      end
    end
  end
end
