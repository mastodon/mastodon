require 'set'
module ActiveModelSerializers
  module Test
    module Serializer
      extend ActiveSupport::Concern

      included do
        setup :setup_serialization_subscriptions
        teardown :teardown_serialization_subscriptions
      end

      # Asserts that the request was rendered with the appropriate serializers.
      #
      #  # assert that the "PostSerializer" serializer was rendered
      #  assert_serializer "PostSerializer"
      #
      #  # return a custom error message
      #  assert_serializer "PostSerializer", "PostSerializer not rendered"
      #
      #  # assert that the instance of PostSerializer was rendered
      #  assert_serializer PostSerializer
      #
      #  # assert that the "PostSerializer" serializer was rendered
      #  assert_serializer :post_serializer
      #
      #  # assert that the rendered serializer starts with "Post"
      #  assert_serializer %r{\APost.+\Z}
      #
      #  # assert that no serializer was rendered
      #  assert_serializer nil
      #
      def assert_serializer(expectation, message = nil)
        @assert_serializer.expectation = expectation
        @assert_serializer.message = message
        @assert_serializer.response = response
        assert(@assert_serializer.matches?, @assert_serializer.message)
      end

      class AssertSerializer
        attr_reader :serializers, :message
        attr_accessor :response, :expectation

        def initialize
          @serializers = Set.new
          @_subscribers = []
        end

        def message=(message)
          @message = message || "expecting <#{expectation.inspect}> but rendering with <#{serializers.to_a}>"
        end

        def matches?
          # Force body to be read in case the template is being streamed.
          response.body

          case expectation
          when a_serializer? then matches_class?
          when Symbol        then matches_symbol?
          when String        then matches_string?
          when Regexp        then matches_regexp?
          when NilClass      then matches_nil?
          else fail ArgumentError, 'assert_serializer only accepts a String, Symbol, Regexp, ActiveModel::Serializer, or nil'
          end
        end

        def subscribe
          @_subscribers << ActiveSupport::Notifications.subscribe(event_name) do |_name, _start, _finish, _id, payload|
            serializer = payload[:serializer].name
            serializers << serializer
          end
        end

        def unsubscribe
          @_subscribers.each do |subscriber|
            ActiveSupport::Notifications.unsubscribe(subscriber)
          end
        end

        private

        def matches_class?
          serializers.include?(expectation.name)
        end

        def matches_symbol?
          camelize_expectation = expectation.to_s.camelize
          serializers.include?(camelize_expectation)
        end

        def matches_string?
          !expectation.empty? && serializers.include?(expectation)
        end

        def matches_regexp?
          serializers.any? do |serializer|
            serializer.match(expectation)
          end
        end

        def matches_nil?
          serializers.empty?
        end

        def a_serializer?
          ->(exp) { exp.is_a?(Class) && exp < ActiveModel::Serializer }
        end

        def event_name
          ::ActiveModelSerializers::Logging::RENDER_EVENT
        end
      end

      private

      def setup_serialization_subscriptions
        @assert_serializer = AssertSerializer.new
        @assert_serializer.subscribe
      end

      def teardown_serialization_subscriptions
        @assert_serializer.unsubscribe
      end
    end
  end
end
