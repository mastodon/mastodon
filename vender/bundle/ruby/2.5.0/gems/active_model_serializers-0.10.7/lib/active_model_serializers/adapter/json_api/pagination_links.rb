module ActiveModelSerializers
  module Adapter
    class JsonApi < Base
      class PaginationLinks
        MissingSerializationContextError = Class.new(KeyError)
        FIRST_PAGE = 1

        attr_reader :collection, :context

        def initialize(collection, adapter_options)
          @collection = collection
          @adapter_options = adapter_options
          @context = adapter_options.fetch(:serialization_context) do
            fail MissingSerializationContextError, <<-EOF.freeze
 JsonApi::PaginationLinks requires a ActiveModelSerializers::SerializationContext.
 Please pass a ':serialization_context' option or
 override CollectionSerializer#paginated? to return 'false'.
            EOF
          end
        end

        def as_json
          {
            self:  location_url,
            first: first_page_url,
            prev:  prev_page_url,
            next:  next_page_url,
            last:  last_page_url
          }
        end

        protected

        attr_reader :adapter_options

        private

        def location_url
          url_for_page(collection.current_page)
        end

        def first_page_url
          url_for_page(1)
        end

        def last_page_url
          if collection.total_pages == 0
            url_for_page(FIRST_PAGE)
          else
            url_for_page(collection.total_pages)
          end
        end

        def prev_page_url
          return nil if collection.current_page == FIRST_PAGE
          url_for_page(collection.current_page - FIRST_PAGE)
        end

        def next_page_url
          return nil if collection.total_pages == 0 || collection.current_page == collection.total_pages
          url_for_page(collection.next_page)
        end

        def url_for_page(number)
          params = query_parameters.dup
          params[:page] = { size: per_page, number: number }
          "#{url(adapter_options)}?#{params.to_query}"
        end

        def url(options = {})
          @url ||= options.fetch(:links, {}).fetch(:self, nil) || request_url
        end

        def request_url
          @request_url ||= context.request_url
        end

        def query_parameters
          @query_parameters ||= context.query_parameters
        end

        def per_page
          @per_page ||= collection.try(:per_page) || collection.try(:limit_value) || collection.size
        end
      end
    end
  end
end
