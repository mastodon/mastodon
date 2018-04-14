# Copyright (c) Chad Fowler, Rich Kilmer, Jim Weirich and others.
# Portions copyright (c) Engine Yard and Andre Arko
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

module Hashie
  module Extensions
    class RubyVersion
      include Comparable

      attr_accessor :segments

      def initialize(version)
        @segments = split_to_segments(version)
      end

      def <=>(other)
        lhsegments = segments
        rhsegments = other.segments

        lhsize = lhsegments.size
        rhsize = rhsegments.size
        limit  = (lhsize > rhsize ? lhsize : rhsize) - 1

        i = 0

        while i <= limit
          lhs = lhsegments[i] || 0
          rhs = rhsegments[i] || 0
          i += 1

          next      if lhs == rhs
          return -1 if lhs.is_a?(String) && rhs.is_a?(Numeric)
          return  1 if lhs.is_a?(Numeric) && rhs.is_a?(String)

          return lhs <=> rhs
        end

        0
      end

      private

      def split_to_segments(version)
        version.scan(/[0-9]+|[a-z]+/i).map do |segment|
          /^\d+$/ =~ segment ? segment.to_i : segment
        end.freeze
      end
    end
  end
end
