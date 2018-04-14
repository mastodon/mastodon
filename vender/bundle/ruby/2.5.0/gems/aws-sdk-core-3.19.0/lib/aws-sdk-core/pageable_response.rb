module Aws

  # Decorates a {Seahorse::Client::Response} with paging methods:
  #
  #     resp = s3.list_objects(params)
  #     resp.last_page?
  #     #=> false
  #
  #     # sends a request to receive the next response page
  #     resp = resp.next_page
  #     resp.last_page?
  #     #=> true
  #
  #     resp.next_page
  #     #=> raises PageableResponse::LastPageError
  #
  # You can enumerate all response pages with a block
  #
  #     ec2.describe_instances(params).each do |page|
  #       # yields once per page
  #       page.reservations.each do |r|
  #         # ...
  #       end
  #     end
  #
  # Or using {#next_page} and {#last_page?}:
  #
  #     resp.last_page?
  #     resp = resp.next_page until resp.last_page?
  #
  module PageableResponse

    def self.extended(base)
      base.send(:extend, Enumerable)
      base.send(:extend, UnsafeEnumerableMethods)
      base.instance_variable_set("@last_page", nil)
      base.instance_variable_set("@more_results", nil)
    end

    # @return [Paging::Pager]
    attr_accessor :pager

    # Returns `true` if there are no more results.  Calling {#next_page}
    # when this method returns `false` will raise an error.
    # @return [Boolean]
    def last_page?
      if @last_page.nil?
        @last_page = !@pager.truncated?(self)
      end
      @last_page
    end

    # Returns `true` if there are more results.  Calling {#next_page} will
    # return the next response.
    # @return [Boolean]
    def next_page?
      !last_page?
    end

    # @return [Seahorse::Client::Response]
    def next_page(params = {})
      if last_page?
        raise LastPageError.new(self)
      else
        next_response(params)
      end
    end

    # Yields the current and each following response to the given block.
    # @yieldparam [Response] response
    # @return [Enumerable,nil] Returns a new Enumerable if no block is given.
    def each(&block)
      return enum_for(:each_page) unless block_given?
      response = self
      yield(response)
      until response.last_page?
        response = response.next_page
        yield(response)
      end
    end
    alias each_page each

    private

    # @param [Hash] params A hash of additional request params to
    #   merge into the next page request.
    # @return [Seahorse::Client::Response] Returns the next page of
    #   results.
    def next_response(params)
      params = next_page_params(params)
      request = context.client.build_request(context.operation_name, params)
      request.send_request
    end

    # @param [Hash] params A hash of additional request params to
    #   merge into the next page request.
    # @return [Hash] Returns the hash of request parameters for the
    #   next page, merging any given params.
    def next_page_params(params)
      context[:original_params].merge(@pager.next_tokens(self).merge(params))
    end

    # Raised when calling {PageableResponse#next_page} on a pager that
    # is on the last page of results.  You can call {PageableResponse#last_page?}
    # or {PageableResponse#next_page?} to know if there are more pages.
    class LastPageError < RuntimeError

      # @param [Seahorse::Client::Response] response
      def initialize(response)
        @response = response
        super("unable to fetch next page, end of results reached")
      end

      # @return [Seahorse::Client::Response]
      attr_reader :response

    end

    # A handful of Enumerable methods, such as #count are not safe
    # to call on a pageable response, as this would trigger n api calls
    # simply to count the number of response pages, when likely what is
    # wanted is to access count on the data. Same for #to_h.
    # @api private
    module UnsafeEnumerableMethods

      def count
        if data.respond_to?(:count)
          data.count
        else
          raise NoMethodError, "undefined method `count'"
        end
      end

      def respond_to?(method_name, *args)
        if method_name == :count
          data.respond_to?(:count)
        else
          super
        end
      end

      def to_h
        data.to_h
      end

    end
  end
end
