# frozen_string_literal: true

module Settings
  module Exports
    class FavouritePostsController < BaseController
      private

      def export_data
        @export.to_favourite_posts_csv
      end
    end
  end
end
