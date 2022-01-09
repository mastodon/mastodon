# frozen_string_literal: true

module Enumerable
  # TODO: Remove this once stop to support Ruby 2.6
  if RUBY_VERSION < '2.7.0'
    def filter_map
      if block_given?
        result = []
        each do |element|
          res = yield element
          result << res if res
        end
        result
      else
        Enumerator.new do |yielder|
          result = []
          each do |element|
            res = yielder.yield element
            result << res if res
          end
          result
        end
      end
    end
  end
end
