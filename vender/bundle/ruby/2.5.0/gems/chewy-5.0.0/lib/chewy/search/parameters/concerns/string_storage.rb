module Chewy
  module Search
    class Parameters
      # Just a simple value storage, all the values are coerced to string.
      module StringStorage
      private

        def normalize(value)
          value.to_s if value.present?
        end
      end
    end
  end
end
