# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module RDF
  class Node
    # Odd case of appending to a BNode identifier
    def +(value)
      Node.new(id + value.to_s)
    end
  end
end

class Array
  # Sort values, but impose special keyword ordering
  # @yield a, b
  # @yieldparam [Object] a
  # @yieldparam [Object] b
  # @yieldreturn [Integer]
  # @return [Array]
  KW_ORDER = %w(@base @id @value @type @language @vocab @container @graph @list @set @index).freeze
  KW_ORDER_CACHE = KW_ORDER.each_with_object({}) do |kw, memo|
    memo[kw] = "@#{KW_ORDER.index(kw)}"
  end.freeze

  # Order, considering keywords to come before other strings
  def kw_sort
    self.sort do |a, b|
      KW_ORDER_CACHE.fetch(a, a) <=> KW_ORDER_CACHE.fetch(b, b)
    end
  end

  # Order terms, length first, then lexographically
  def term_sort
    self.sort do |a, b|
      len_diff = a.length <=> b.length
      len_diff == 0 ? a <=> b : len_diff
    end
  end
end
