# frozen_string_literal: true

module Settings
  module Exports
    class BlockedAccountsController < ApplicationController
      before_action :authenticate_user!

      def index
        export_data = Export.new(current_account.blocking).to_csv

        respond_to do |format|
          format.csv { send_data export_data, filename: 'blocking.csv' }
        end
      end
    end
  end
end
