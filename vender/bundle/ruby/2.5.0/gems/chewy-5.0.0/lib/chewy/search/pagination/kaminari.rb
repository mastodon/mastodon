module Chewy
  module Search
    module Pagination
      # This module provides `Kaminari` support for {Chewy::Search::Request}
      # It is included automatically if `Kaminari` is available.
      #
      # @example
      #   PlacesIndex.all.page(3).per(10).order(:name)
      #   # => <PlacesIndex::Query {..., :body=>{:size=>10, :from=>20, :sort=>["name"]}}>
      module Kaminari
        extend ActiveSupport::Concern

        included do
          include ::Kaminari::PageScopeMethods

          delegate :default_per_page, :max_per_page, :max_pages, to: :_kaminari_config

          class_eval <<-METHOD, __FILE__, __LINE__ + 1
            def #{::Kaminari.config.page_method_name}(num = 1)
              limit(limit_value).offset(limit_value * ([num.to_i, 1].max - 1))
            end
          METHOD
        end

        def limit_value
          (raw_limit_value || default_per_page).to_i
        end

        def offset_value
          raw_offset_value.to_i
        end

      private

        def _kaminari_config
          ::Kaminari.config
        end

        def paginated_collection(collection)
          ::Kaminari.paginate_array(collection, limit: limit_value, offset: offset_value, total_count: total_count)
        end
      end
    end
  end
end
