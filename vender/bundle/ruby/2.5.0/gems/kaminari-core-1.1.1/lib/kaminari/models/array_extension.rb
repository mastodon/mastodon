# frozen_string_literal: true
require 'active_support/core_ext/module'
module Kaminari
  # Kind of Array that can paginate
  class PaginatableArray < Array
    include Kaminari::ConfigurationMethods::ClassMethods

    ENTRY = 'entry'.freeze

    attr_internal_accessor :limit_value, :offset_value

    # ==== Options
    # * <tt>:limit</tt> - limit
    # * <tt>:offset</tt> - offset
    # * <tt>:total_count</tt> - total_count
    # * <tt>:padding</tt> - padding
    def initialize(original_array = [], limit: nil, offset: nil, total_count: nil, padding: nil)
      @_original_array, @_limit_value, @_offset_value, @_total_count, @_padding = original_array, (limit || default_per_page).to_i, offset.to_i, total_count, padding.to_i

      if limit && offset
        extend Kaminari::PageScopeMethods
      end

      if @_total_count && (@_total_count <= original_array.count)
        original_array = original_array.first(@_total_count)[@_offset_value, @_limit_value]
      end

      unless @_total_count
        original_array = original_array[@_offset_value, @_limit_value]
      end

      super(original_array || [])
    end

    # Used for page_entry_info
    def entry_name(options = {})
      I18n.t('helpers.page_entries_info.entry', options.reverse_merge(default: ENTRY.pluralize(options[:count])))
    end

    # items at the specified "page"
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{Kaminari.config.page_method_name}(num = 1)
        offset(limit_value * ((num = num.to_i - 1) < 0 ? 0 : num))
      end
    RUBY

    # returns another chunk of the original array
    def limit(num)
      self.class.new @_original_array, limit: num, offset: @_offset_value, total_count: @_total_count, padding: @_padding
    end

    # total item numbers of the original array
    def total_count
      @_total_count || @_original_array.length
    end

    # returns another chunk of the original array
    def offset(num)
      self.class.new @_original_array, limit: @_limit_value, offset: num, total_count: @_total_count, padding: @_padding
    end
  end

  # Wrap an Array object to make it paginatable
  # ==== Options
  # * <tt>:limit</tt> - limit
  # * <tt>:offset</tt> - offset
  # * <tt>:total_count</tt> - total_count
  # * <tt>:padding</tt> - padding
  def self.paginate_array(array, limit: nil, offset: nil, total_count: nil, padding: nil)
    PaginatableArray.new array, limit: limit, offset: offset, total_count: total_count, padding: padding
  end
end
