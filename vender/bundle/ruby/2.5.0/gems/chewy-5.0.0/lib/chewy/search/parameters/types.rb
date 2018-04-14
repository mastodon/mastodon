require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # A standard string array storage with one exception: rendering is empty.
      #
      # @see Chewy::Search::Parameters::StringArrayStorage
      class Types < Storage
        include StringArrayStorage

        # Doesn't render anything, has specialized rendering logic in
        # {Chewy::Search::Request}
        #
        # @return [nil]
        def render; end
      end
    end
  end
end
