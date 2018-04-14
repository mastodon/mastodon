# frozen_string_literal: true

module Kaminari
  module Helpers
    module HelperMethods
      # A helper that renders the pagination links.
      #
      #   <%= paginate @articles %>
      #
      # ==== Options
      # * <tt>:window</tt> - The "inner window" size (4 by default).
      # * <tt>:outer_window</tt> - The "outer window" size (0 by default).
      # * <tt>:left</tt> - The "left outer window" size (0 by default).
      # * <tt>:right</tt> - The "right outer window" size (0 by default).
      # * <tt>:params</tt> - url_for parameters for the links (:controller, :action, etc.)
      # * <tt>:param_name</tt> - parameter name for page number in the links (:page by default)
      # * <tt>:remote</tt> - Ajax? (false by default)
      # * <tt>:paginator_class</tt> - Specify a custom Paginator (Kaminari::Helpers::Paginator by default)
      # * <tt>:template</tt> - Specify a custom template renderer for rendering the Paginator (receiver by default)
      # * <tt>:ANY_OTHER_VALUES</tt> - Any other hash key & values would be directly passed into each tag as :locals value.
      def paginate(scope, paginator_class: Kaminari::Helpers::Paginator, template: nil, **options)
        options[:total_pages] ||= scope.total_pages
        options.reverse_merge! current_page: scope.current_page, per_page: scope.limit_value, remote: false

        paginator = paginator_class.new (template || self), options
        paginator.to_s
      end

      # A simple "Twitter like" pagination link that creates a link to the previous page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= link_to_previous_page @items, 'Previous Page' %>
      #
      # Ajax:
      #
      #   <%= link_to_previous_page @items, 'Previous Page', remote: true %>
      #
      # By default, it renders nothing if there are no more results on the previous page.
      # You can customize this output by passing a block.
      #
      #   <%= link_to_previous_page @users, 'Previous Page' do %>
      #     <span>At the Beginning</span>
      #   <% end %>
      def link_to_previous_page(scope, name, **options)
        prev_page = path_to_prev_page(scope, options)

        options.except! :params, :param_name
        options[:rel] ||= 'prev'

        link_to_if prev_page, name, prev_page, options do
          yield if block_given?
        end
      end
      alias link_to_prev_page link_to_previous_page

      # A simple "Twitter like" pagination link that creates a link to the next page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= link_to_next_page @items, 'Next Page' %>
      #
      # Ajax:
      #
      #   <%= link_to_next_page @items, 'Next Page', remote: true %>
      #
      # By default, it renders nothing if there are no more results on the next page.
      # You can customize this output by passing a block.
      #
      #   <%= link_to_next_page @users, 'Next Page' do %>
      #     <span>No More Pages</span>
      #   <% end %>
      def link_to_next_page(scope, name, **options)
        next_page = path_to_next_page(scope, options)

        options.except! :params, :param_name
        options[:rel] ||= 'next'

        link_to_if next_page, name, next_page, options do
          yield if block_given?
        end
      end

      # Renders a helpful message with numbers of displayed vs. total entries.
      # Ported from mislav/will_paginate
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= page_entries_info @posts %>
      #   #-> Displaying posts 6 - 10 of 26 in total
      #
      # By default, the message will use the humanized class name of objects
      # in collection: for instance, "project types" for ProjectType models.
      # The namespace will be cutted out and only the last name will be used.
      # Override this with the <tt>:entry_name</tt> parameter:
      #
      #   <%= page_entries_info @posts, entry_name: 'item' %>
      #   #-> Displaying items 6 - 10 of 26 in total
      def page_entries_info(collection, entry_name: nil)
        entry_name = if entry_name
                       entry_name.pluralize(collection.size, I18n.locale)
                     else
                       collection.entry_name(count: collection.size).downcase
                     end

        if collection.total_pages < 2
          t('helpers.page_entries_info.one_page.display_entries', entry_name: entry_name, count: collection.total_count)
        else
          t('helpers.page_entries_info.more_pages.display_entries', entry_name: entry_name, first: collection.offset_value + 1, last: [collection.offset_value + collection.limit_value, collection.total_count].min, total: collection.total_count)
        end.html_safe
      end

      # Renders rel="next" and rel="prev" links to be used in the head.
      #
      # ==== Examples
      # Basic usage:
      #
      #   In head:
      #   <head>
      #     <title>My Website</title>
      #     <%= yield :head %>
      #   </head>
      #
      #   Somewhere in body:
      #   <% content_for :head do %>
      #     <%= rel_next_prev_link_tags @items %>
      #   <% end %>
      #
      #   #-> <link rel="next" href="/items/page/3" /><link rel="prev" href="/items/page/1" />
      #
      def rel_next_prev_link_tags(scope, options = {})
        next_page = path_to_next_page(scope, options)
        prev_page = path_to_prev_page(scope, options)

        output = String.new
        output << tag(:link, rel: "next", href: next_page) if next_page
        output << tag(:link, rel: "prev", href: prev_page) if prev_page
        output.html_safe
      end

      # A helper that calculates the path to the next page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= path_to_next_page @items %>
      #   #-> /items?page=2
      #
      # It will return `nil` if there is no next page.
      def path_to_next_page(scope, options = {})
        Kaminari::Helpers::NextPage.new(self, options.reverse_merge(current_page: scope.current_page)).url if scope.next_page
      end

      # A helper that calculates the path to the previous page.
      #
      # ==== Examples
      # Basic usage:
      #
      #   <%= path_to_prev_page @items %>
      #   #-> /items
      #
      # It will return `nil` if there is no previous page.
      def path_to_prev_page(scope, options = {})
        Kaminari::Helpers::PrevPage.new(self, options.reverse_merge(current_page: scope.current_page)).url if scope.prev_page
      end
    end
  end
end
