require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # @see Chewy::Search::Parameters::StringArrayStorage
      class DocvalueFields < Storage
        include StringArrayStorage
      end
    end
  end
end
