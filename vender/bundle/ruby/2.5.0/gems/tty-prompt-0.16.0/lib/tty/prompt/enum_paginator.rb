# encoding: utf-8
# frozen_string_literal: true

require_relative 'paginator'

module TTY
  class Prompt
    class EnumPaginator < Paginator
      # Paginate list of choices based on current active choice.
      # Move entire pages.
      #
      # @api public
      def paginate(list, active, per_page = nil, &block)
        default_size = (list.size <= DEFAULT_PAGE_SIZE ? list.size : DEFAULT_PAGE_SIZE)
        @per_page = @per_page || per_page || default_size

        check_page_size!

        # Don't paginate short lists
        if list.size <= @per_page
          @lower_index = 0
          @upper_index = list.size - 1
          if block
            return list.each_with_index(&block)
          else
            return list.each_with_index.to_enum
          end
        end

        unless active.nil? # User may input index out of range
          @last_index = active
        end
        page  = (@last_index / @per_page.to_f).ceil
        pages = (list.size / @per_page.to_f).ceil
        if page == 0
          @lower_index = 0
          @upper_index = @lower_index + @per_page - 1
        elsif page > 0 && page <= pages
          @lower_index = (page - 1) * @per_page
          @upper_index = @lower_index + @per_page - 1
        else
          @upper_index = list.size - 1
          @lower_index = @upper_index - @per_page + 1
        end

        sliced_list = list[@lower_index..@upper_index]
        indices = (@lower_index..@upper_index)

        if block
          sliced_list.each_with_index do |item, index|
            block[item, @lower_index + index]
          end
        else
          sliced_list.zip(indices).to_enum unless block_given?
        end
      end
    end # EnumPaginator
  end # Prompt
end # TTY
