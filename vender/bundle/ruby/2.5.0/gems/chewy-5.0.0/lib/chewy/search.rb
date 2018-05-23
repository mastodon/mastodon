require 'chewy/search/scoping'
require 'chewy/query'
require 'chewy/search/scrolling'
require 'chewy/search/query_proxy'
require 'chewy/search/parameters'
require 'chewy/search/response'
require 'chewy/search/loader'
require 'chewy/search/request'
require 'chewy/search/pagination/kaminari'
require 'chewy/search/pagination/will_paginate'

module Chewy
  # This module being included to any provides an interface to the
  # request DSL. By default it is included to {Chewy::Index} and
  # {Chewy::Type}.
  #
  # The class used as a request DSL provider is
  # inherited from {Chewy::Search::Request} by default, but if you
  # need ES < 2.0 DSL support - you can switch it to {Chewy::Query}
  # using {Chewy::Config#search_class}
  #
  # Also, the search class is refined with one of the pagination-
  # providing modules: {Chewy::Search::Pagination::Kaminari} or
  # {Chewy::Search::Pagination::WillPaginate}.
  #
  # @example
  #   PlacesIndex.query(match: {name: 'Moscow'})
  #   PlacesIndex::City.query(match: {name: 'Moscow'})
  # @see Chewy::Index
  # @see Chewy::Type
  # @see Chewy::Search::Request
  # @see Chewy::Search::ClassMethods
  # @see Chewy::Search::Pagination::Kaminari
  # @see Chewy::Search::Pagination::WillPaginate
  module Search
    extend ActiveSupport::Concern

    module ClassMethods
      # This is the entry point for the request composition, however,
      # most of the {Chewy::Search::Request} methods are delegated
      # directly as well.
      #
      # This method also provides an ability to use names scopes.
      #
      # @example
      #   PlacesIndex.all.limit(10)
      #   # is basically the same as:
      #   PlacesIndex.limit(10)
      # @see Chewy::Search::Request
      # @see Chewy::Search::Scoping
      # @return [Chewy::Search::Request] request instance
      def all
        search_class.scopes.last || search_class.new(self)
      end

      # A simple way to execute search string query.
      #
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/current/search-uri-request.html
      # @return [Hash] the request result
      def search_string(query, options = {})
        options = options.merge(
          index: all._indexes.map(&:index_name),
          type: all._types.map(&:type_name),
          q: query
        )
        Chewy.client.search(options)
      end

      # Delegates methods from the request class to the index or type class
      #
      # @example
      #   PlacesIndex.query(match: {name: 'Moscow'})
      #   PlacesIndex::City.query(match: {name: 'Moscow'})
      def method_missing(name, *args, &block)
        if search_class::DELEGATED_METHODS.include?(name)
          all.send(name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, _)
        search_class::DELEGATED_METHODS.include?(name) || super
      end

    private

      def search_class
        @search_class ||= build_search_class(Chewy.search_class)
      end

      def build_search_class(base)
        search_class = Class.new(base)

        if self < Chewy::Type
          index_scopes = index.scopes - scopes
          delegate_scoped index, search_class, index_scopes
        end

        delegate_scoped self, search_class, scopes
        const_set('Query', search_class)
      end

      def delegate_scoped(source, destination, methods)
        methods.each do |method|
          destination.class_eval do
            define_method method do |*args, &block|
              scoping { source.public_send(method, *args, &block) }
            end
          end
        end
      end
    end
  end
end
