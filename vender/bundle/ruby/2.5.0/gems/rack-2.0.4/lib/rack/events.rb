require 'rack/response'
require 'rack/body_proxy'

module Rack
  ### This middleware provides hooks to certain places in the request /
  #response lifecycle.  This is so that middleware that don't need to filter
  #the response data can safely leave it alone and not have to send messages
  #down the traditional "rack stack".
  #
  # The events are:
  #
  # * on_start(request, response)
  #
  #   This event is sent at the start of the request, before the next
  #   middleware in the chain is called.  This method is called with a request
  #   object, and a response object.  Right now, the response object is always
  #   nil, but in the future it may actually be a real response object.
  #
  # * on_commit(request, response)
  #
  #   The response has been committed.  The application has returned, but the
  #   response has not been sent to the webserver yet.  This method is always
  #   called with a request object and the response object.  The response
  #   object is constructed from the rack triple that the application returned.
  #   Changes may still be made to the response object at this point.
  #
  # * on_send(request, response)
  #
  #   The webserver has started iterating over the response body and presumably
  #   has started sending data over the wire. This method is always called with
  #   a request object and the response object.  The response object is
  #   constructed from the rack triple that the application returned.  Changes
  #   SHOULD NOT be made to the response object as the webserver has already
  #   started sending data.  Any mutations will likely result in an exception.
  #
  # * on_finish(request, response)
  #
  #   The webserver has closed the response, and all data has been written to
  #   the response socket.  The request and response object should both be
  #   read-only at this point.  The body MAY NOT be available on the response
  #   object as it may have been flushed to the socket.
  #
  # * on_error(request, response, error)
  #
  #   An exception has occurred in the application or an `on_commit` event.
  #   This method will get the request, the response (if available) and the
  #   exception that was raised.
  #
  # ## Order
  #
  # `on_start` is called on the handlers in the order that they were passed to
  # the constructor.  `on_commit`, on_send`, `on_finish`, and `on_error` are
  # called in the reverse order.  `on_finish` handlers are called inside an
  # `ensure` block, so they are guaranteed to be called even if something
  # raises an exception.  If something raises an exception in a `on_finish`
  # method, then nothing is guaranteed.

  class Events
    module Abstract
      def on_start req, res
      end

      def on_commit req, res
      end

      def on_send req, res
      end

      def on_finish req, res
      end

      def on_error req, res, e
      end
    end

    class EventedBodyProxy < Rack::BodyProxy # :nodoc:
      attr_reader :request, :response

      def initialize body, request, response, handlers, &block
        super(body, &block)
        @request  = request
        @response = response
        @handlers = handlers
      end

      def each
        @handlers.reverse_each { |handler| handler.on_send request, response }
        super
      end
    end

    class BufferedResponse < Rack::Response::Raw # :nodoc:
      attr_reader :body

      def initialize status, headers, body
        super(status, headers)
        @body = body
      end

      def to_a; [status, headers, body]; end
    end

    def initialize app, handlers
      @app      = app
      @handlers = handlers
    end

    def call env
      request = make_request env
      on_start request, nil

      begin
        status, headers, body = @app.call request.env
        response = make_response status, headers, body
        on_commit request, response
      rescue StandardError => e
        on_error request, response, e
        on_finish request, response
        raise
      end

      body = EventedBodyProxy.new(body, request, response, @handlers) do
        on_finish request, response
      end
      [response.status, response.headers, body]
    end

    private

    def on_error request, response, e
      @handlers.reverse_each { |handler| handler.on_error request, response, e }
    end

    def on_commit request, response
      @handlers.reverse_each { |handler| handler.on_commit request, response }
    end

    def on_start request, response
      @handlers.each { |handler| handler.on_start request, nil }
    end

    def on_finish request, response
      @handlers.reverse_each { |handler| handler.on_finish request, response }
    end

    def make_request env
      Rack::Request.new env
    end

    def make_response status, headers, body
      BufferedResponse.new status, headers, body
    end
  end
end
