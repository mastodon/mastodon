# frozen_string_literal: true
require 'active_support/inflector'
require 'kaminari/helpers/tags'

module Kaminari
  module Helpers
    # The main container tag
    class Paginator < Tag
      def initialize(template, window: nil, outer_window: Kaminari.config.outer_window, left: Kaminari.config.left, right: Kaminari.config.right, inner_window: Kaminari.config.window, **options) #:nodoc:
        @window_options = {window: window || inner_window, left: left.zero? ? outer_window : left, right: right.zero? ? outer_window : right}

        @template, @options, @theme, @views_prefix, @last = template, options, options[:theme], options[:views_prefix], nil
        @window_options.merge! @options
        @window_options[:current_page] = @options[:current_page] = PageProxy.new(@window_options, @options[:current_page], nil)

        #XXX Using parent template's buffer class for rendering each partial here. This might cause problems if the handler mismatches
        @output_buffer = if defined?(::ActionView::OutputBuffer)
          ::ActionView::OutputBuffer.new
        elsif template.instance_variable_get(:@output_buffer)
          template.instance_variable_get(:@output_buffer).class.new
        else
          ActiveSupport::SafeBuffer.new
        end
      end

      # render given block as a view template
      def render(&block)
        instance_eval(&block) if @options[:total_pages] > 1
        @output_buffer
      end

      # enumerate each page providing PageProxy object as the block parameter
      # Because of performance reason, this doesn't actually enumerate all pages but pages that are seemingly relevant to the paginator.
      # "Relevant" pages are:
      # * pages inside the left outer window plus one for showing the gap tag
      # * pages inside the inner window plus one on the left plus one on the right for showing the gap tags
      # * pages inside the right outer window plus one for showing the gap tag
      def each_relevant_page
        return to_enum(:each_relevant_page) unless block_given?

        relevant_pages(@window_options).each do |page|
          yield PageProxy.new(@window_options, page, @last)
        end
      end
      alias each_page each_relevant_page

      def relevant_pages(options)
        left_window_plus_one = [*1..options[:left] + 1]
        right_window_plus_one = [*options[:total_pages] - options[:right]..options[:total_pages]]
        inside_window_plus_each_sides = [*options[:current_page] - options[:window] - 1..options[:current_page] + options[:window] + 1]

        (left_window_plus_one | inside_window_plus_each_sides | right_window_plus_one).sort.reject {|x| (x < 1) || (x > options[:total_pages])}
      end
      private :relevant_pages

      def page_tag(page)
        @last = Page.new @template, @options.merge(page: page)
      end

      %w[first_page prev_page next_page last_page gap].each do |tag|
        eval <<-DEF, nil, __FILE__, __LINE__ + 1
          def #{tag}_tag
            @last = #{tag.classify}.new @template, @options
          end
        DEF
      end

      def to_s #:nodoc:
        Thread.current[:kaminari_rendering] = true
        super @window_options.merge paginator: self
      ensure
        Thread.current[:kaminari_rendering] = false
      end

      # delegates view helper methods to @template
      def method_missing(name, *args, &block)
        @template.respond_to?(name) ? @template.send(name, *args, &block) : super
      end
      private :method_missing

      # Wraps a "page number" and provides some utility methods
      class PageProxy
        include Comparable

        def initialize(options, page, last) #:nodoc:
          @options, @page, @last = options, page, last
        end

        # the page number
        def number
          @page
        end

        # current page or not
        def current?
          @page == @options[:current_page]
        end

        # the first page or not
        def first?
          @page == 1
        end

        # the last page or not
        def last?
          @page == @options[:total_pages]
        end

        # the previous page or not
        def prev?
          @page == @options[:current_page] - 1
        end

        # the next page or not
        def next?
          @page == @options[:current_page] + 1
        end

        # relationship with the current page
        def rel
          if next?
            'next'
          elsif prev?
            'prev'
          end
        end

        # within the left outer window or not
        def left_outer?
          @page <= @options[:left]
        end

        # within the right outer window or not
        def right_outer?
          @options[:total_pages] - @page < @options[:right]
        end

        # inside the inner window or not
        def inside_window?
          (@options[:current_page] - @page).abs <= @options[:window]
        end

        # Current page is an isolated gap or not
        def single_gap?
          ((@page == @options[:current_page] - @options[:window] - 1) && (@page == @options[:left] + 1)) ||
            ((@page == @options[:current_page] + @options[:window] + 1) && (@page == @options[:total_pages] - @options[:right]))
        end

        # The page number exceeds the range of pages or not
        def out_of_range?
          @page > @options[:total_pages]
        end

        # The last rendered tag was "truncated" or not
        def was_truncated?
          @last.is_a? Gap
        end

        #Should we display the link tag?
        def display_tag?
          left_outer? || right_outer? || inside_window? || single_gap?
        end

        def to_i #:nodoc:
          number
        end

        def to_s #:nodoc:
          number.to_s
        end

        def +(other) #:nodoc:
          to_i + other.to_i
        end

        def -(other) #:nodoc:
          to_i - other.to_i
        end

        def <=>(other) #:nodoc:
          to_i <=> other.to_i
        end
      end
    end
  end
end
