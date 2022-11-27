# frozen_string_literal: true

module Settings
  module Exports
    class FollowingTagsController < BaseController
      include ExportControllerConcern

      def index
        send_export_file
      end

      private

      def export_data
        @export.to_following_tags_csv
      end
    end
  end
end
