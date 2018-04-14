# WARNING ABOUT GENERATED CODE
#
# This file is generated. See the contributing guide for more information:
# https://github.com/aws/aws-sdk-ruby/blob/master/CONTRIBUTING.md
#
# WARNING ABOUT GENERATED CODE

require 'aws-sdk-core/waiters'

module Aws::S3
  module Waiters

    class BucketExists

      # @param [Hash] options
      # @option options [required, Client] :client
      # @option options [Integer] :max_attempts (20)
      # @option options [Integer] :delay (5)
      # @option options [Proc] :before_attempt
      # @option options [Proc] :before_wait
      def initialize(options)
        @client = options.fetch(:client)
        @waiter = Aws::Waiters::Waiter.new({
          max_attempts: 20,
          delay: 5,
          poller: Aws::Waiters::Poller.new(
            operation_name: :head_bucket,
            acceptors: [
              {
                "expected" => 200,
                "matcher" => "status",
                "state" => "success"
              },
              {
                "expected" => 301,
                "matcher" => "status",
                "state" => "success"
              },
              {
                "expected" => 403,
                "matcher" => "status",
                "state" => "success"
              },
              {
                "expected" => 404,
                "matcher" => "status",
                "state" => "retry"
              }
            ]
          )
        }.merge(options))
      end

      # @option (see Client#head_bucket)
      # @return (see Client#head_bucket)
      def wait(params = {})
        @waiter.wait(client: @client, params: params)
      end

      # @api private
      attr_reader :waiter

    end

    class BucketNotExists

      # @param [Hash] options
      # @option options [required, Client] :client
      # @option options [Integer] :max_attempts (20)
      # @option options [Integer] :delay (5)
      # @option options [Proc] :before_attempt
      # @option options [Proc] :before_wait
      def initialize(options)
        @client = options.fetch(:client)
        @waiter = Aws::Waiters::Waiter.new({
          max_attempts: 20,
          delay: 5,
          poller: Aws::Waiters::Poller.new(
            operation_name: :head_bucket,
            acceptors: [{
              "expected" => 404,
              "matcher" => "status",
              "state" => "success"
            }]
          )
        }.merge(options))
      end

      # @option (see Client#head_bucket)
      # @return (see Client#head_bucket)
      def wait(params = {})
        @waiter.wait(client: @client, params: params)
      end

      # @api private
      attr_reader :waiter

    end

    class ObjectExists

      # @param [Hash] options
      # @option options [required, Client] :client
      # @option options [Integer] :max_attempts (20)
      # @option options [Integer] :delay (5)
      # @option options [Proc] :before_attempt
      # @option options [Proc] :before_wait
      def initialize(options)
        @client = options.fetch(:client)
        @waiter = Aws::Waiters::Waiter.new({
          max_attempts: 20,
          delay: 5,
          poller: Aws::Waiters::Poller.new(
            operation_name: :head_object,
            acceptors: [
              {
                "expected" => 200,
                "matcher" => "status",
                "state" => "success"
              },
              {
                "expected" => 404,
                "matcher" => "status",
                "state" => "retry"
              }
            ]
          )
        }.merge(options))
      end

      # @option (see Client#head_object)
      # @return (see Client#head_object)
      def wait(params = {})
        @waiter.wait(client: @client, params: params)
      end

      # @api private
      attr_reader :waiter

    end

    class ObjectNotExists

      # @param [Hash] options
      # @option options [required, Client] :client
      # @option options [Integer] :max_attempts (20)
      # @option options [Integer] :delay (5)
      # @option options [Proc] :before_attempt
      # @option options [Proc] :before_wait
      def initialize(options)
        @client = options.fetch(:client)
        @waiter = Aws::Waiters::Waiter.new({
          max_attempts: 20,
          delay: 5,
          poller: Aws::Waiters::Poller.new(
            operation_name: :head_object,
            acceptors: [{
              "expected" => 404,
              "matcher" => "status",
              "state" => "success"
            }]
          )
        }.merge(options))
      end

      # @option (see Client#head_object)
      # @return (see Client#head_object)
      def wait(params = {})
        @waiter.wait(client: @client, params: params)
      end

      # @api private
      attr_reader :waiter

    end
  end
end
