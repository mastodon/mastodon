# frozen_string_literal: true

module Settings
  module Exports
    class MutedAccountsController < ApplicationController
      before_action :authenticate_user!

      def index
        export_data = Export.new(current_account.muting).to_csv

        respond_to do |format|
          format.csv { send_data export_data, filename: 'mutes.csv' }
        end
      end
    end
  end
end
