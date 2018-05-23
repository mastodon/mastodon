require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Just a standard string value storage, nothing to see here.
      #
      # @see Chewy::Search::Parameters::StringStorage
      # @see Chewy::Search::Request#timeout
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/common-options.html#time-units
      class Timeout < Storage
        include StringStorage
      end
    end
  end
end
