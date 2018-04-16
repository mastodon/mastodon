# encoding: utf-8
# frozen_string_literal: true
module Mail

  # Field List class provides an enhanced array that keeps a list of 
  # email fields in order.  And allows you to insert new fields without
  # having to worry about the order they will appear in.
  class FieldList < Array

    include Enumerable

    # Insert the field in sorted order.
    #
    # Heavily based on bisect.insort from Python, which is:
    #   Copyright (C) 2001-2013 Python Software Foundation.
    #   Licensed under <http://docs.python.org/license.html>
    #   From <http://hg.python.org/cpython/file/2.7/Lib/bisect.py>
    def <<( new_field )
      lo = 0
      hi = size

      while lo < hi
        mid = (lo + hi).div(2)
        if new_field < self[mid]
          hi = mid
        else
          lo = mid + 1
        end
      end

      insert(lo, new_field)
    end
  end
end
