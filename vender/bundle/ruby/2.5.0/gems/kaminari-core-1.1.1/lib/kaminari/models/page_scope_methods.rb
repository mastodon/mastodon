# frozen_string_literal: true
module Kaminari
  module PageScopeMethods
    # Specify the <tt>per_page</tt> value for the preceding <tt>page</tt> scope
    #   Model.page(3).per(10)
    def per(num, max_per_page: nil)
      max_per_page ||= ((defined?(@_max_per_page) && @_max_per_page) || self.max_per_page)
      @_per = (num || default_per_page).to_i
      if (n = num.to_i) < 0 || !(/^\d/ =~ num.to_s)
        self
      elsif n.zero?
        limit(n)
      elsif max_per_page && (max_per_page < n)
        limit(max_per_page).offset(offset_value / limit_value * max_per_page)
      else
        limit(n).offset(offset_value / limit_value * n)
      end
    end

    def max_paginates_per(new_max_per_page)
      @_max_per_page = new_max_per_page
      per current_per_page, max_per_page: new_max_per_page
    end

    def padding(num)
      num = num.to_i
      raise ArgumentError, "padding must not be negative" if num < 0
      @_padding = num
      offset(offset_value + @_padding)
    end

    # Total number of pages
    def total_pages
      count_without_padding = total_count
      count_without_padding -= @_padding if defined?(@_padding) && @_padding
      count_without_padding = 0 if count_without_padding < 0

      total_pages_count = (count_without_padding.to_f / limit_value).ceil
      max_pages && (max_pages < total_pages_count) ? max_pages : total_pages_count
    rescue FloatDomainError
      raise ZeroPerPageOperation, "The number of total pages was incalculable. Perhaps you called .per(0)?"
    end

    # Current page number
    def current_page
      offset_without_padding = offset_value
      offset_without_padding -= @_padding if defined?(@_padding) && @_padding
      offset_without_padding = 0 if offset_without_padding < 0

      (offset_without_padding / limit_value) + 1
    rescue ZeroDivisionError
      raise ZeroPerPageOperation, "Current page was incalculable. Perhaps you called .per(0)?"
    end

    # Current per-page number
    def current_per_page
      (defined?(@_per) && @_per) || default_per_page
    end

    # Next page number in the collection
    def next_page
      current_page + 1 unless last_page? || out_of_range?
    end

    # Previous page number in the collection
    def prev_page
      current_page - 1 unless first_page? || out_of_range?
    end

    # First page of the collection?
    def first_page?
      current_page == 1
    end

    # Last page of the collection?
    def last_page?
      current_page == total_pages
    end

    # Out of range of the collection?
    def out_of_range?
      current_page > total_pages
    end
  end
end
