require 'active_support/concern'

module Rails
  module Dom
    module Testing
      module Assertions
        module SelectorAssertions
          module CountDescribable
            extend ActiveSupport::Concern

            private
              def count_description(min, max, count) #:nodoc:
                if min && max && (max != min)
                  "between #{min} and #{max} elements"
                elsif min && max && max == min && count
                  "exactly #{count} #{pluralize_element(min)}"
                elsif min && !(min == 1 && max == 1)
                  "at least #{min} #{pluralize_element(min)}"
                elsif max
                  "at most #{max} #{pluralize_element(max)}"
                end
              end

              def pluralize_element(quantity)
                quantity == 1 ? 'element' : 'elements'
              end
          end
        end
      end
    end
  end
end
