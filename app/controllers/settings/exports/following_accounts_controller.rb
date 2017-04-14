# frozen_string_literal: true

module Settings
  module Exports
    class FollowingAccountsController < BaseController
      private

      def export_data
        @export.to_following_accounts_csv
      end
    end
  end
end
