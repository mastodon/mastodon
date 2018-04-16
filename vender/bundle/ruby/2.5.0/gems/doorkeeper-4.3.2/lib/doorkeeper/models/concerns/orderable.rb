module Doorkeeper
  module Models
    module Orderable
      extend ActiveSupport::Concern

      module ClassMethods
        def ordered_by(attribute, direction = :asc)
          order(attribute => direction)
        end
      end
    end
  end
end
