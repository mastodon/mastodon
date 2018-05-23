module Chewy
  module Search
    module Pagination
      # This module provides `WillPaginate` support for {Chewy::Search::Request}
      # It is included automatically if `WillPaginate` is available.
      #
      # @example
      #   PlacesIndex.all.paginate(page: 3, per_page: 10).order(:name)
      #   # => <PlacesIndex::Query {..., :body=>{:size=>10, :from=>20, :sort=>["name"]}}>
      module WillPaginate
        extend ActiveSupport::Concern

        included do
          include ::WillPaginate::CollectionMethods
          attr_reader :current_page, :per_page
        end

        def paginate(options = {})
          @current_page = ::WillPaginate::PageNumber(options[:page] || @current_page || 1)
          @page_multiplier = @current_page - 1
          @per_page = (options[:per_page] || @per_page || ::WillPaginate.per_page).to_i

          # call Chewy::Query methods to limit results
          limit(@per_page).offset(@page_multiplier * @per_page)
        end

        def page(page)
          paginate(page: page)
        end

      private

        def paginated_collection(collection)
          page = current_page || 1
          per = per_page || ::WillPaginate.per_page
          ::WillPaginate::Collection.create(page, per, total_entries) do |pager|
            pager.replace collection
          end
        end
      end
    end
  end
end
