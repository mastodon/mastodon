module Seahorse
  module Client
    class Request

      include HandlerBuilder

      # @param [HandlerList] handlers
      # @param [RequestContext] context
      def initialize(handlers, context)
        @handlers = handlers
        @context = context
      end

      # @return [HandlerList]
      attr_reader :handlers

      # @return [RequestContext]
      attr_reader :context

      # Sends the request, returning a {Response} object.
      #
      #     response = request.send_request
      #
      # # Streaming Responses
      #
      # By default, HTTP responses are buffered into memory.  This can be
      # bad if you are downloading large responses, e.g. large files.
      # You can avoid this by streaming the response to a block or some other
      # target.
      #
      # ## Streaming to a File
      #
      # You can stream the raw HTTP response body to a File, or any IO-like
      # object, by passing the `:target` option.
      #
      #     # create a new file at the given path
      #     request.send_request(target: '/path/to/target/file')
      #
      #     # or provide an IO object to write to
      #     File.open('photo.jpg', 'wb') do |file|
      #       request.send_request(target: file)
      #     end
      #
      # **Please Note**: The target IO object may receive `#truncate(0)`
      # if the request generates a networking error and bytes have already
      # been written to the target.
      #
      # ## Block Streaming
      #
      # Pass a block to `#send_request` and the response will be yielded in
      # chunks to the given block.
      #
      #     # stream the response data
      #     request.send_request do |chunk|
      #       file.write(chunk)
      #     end
      #
      # **Please Note**: When streaming to a block, it is not possible to
      # retry failed requests.
      #
      # @option options [String, IO] :target When specified, the HTTP response
      #   body is written to target.  This is helpful when you are sending
      #   a request that may return a large payload that you don't want to
      #   load into memory.
      #
      # @return [Response]
      #
      def send_request(options = {}, &block)
        @context[:response_target] = options[:target] || block
        @handlers.to_stack.call(@context)
      end

    end
  end
end
