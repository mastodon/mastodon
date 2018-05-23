module Aws
  module Plugins
    # @api private
    class StubResponses < Seahorse::Client::Plugin

      option(:stub_responses,
        default: false,
        doc_type: 'Boolean',
        docstring: <<-DOCS)
Causes the client to return stubbed responses. By default
fake responses are generated and returned. You can specify
the response data to return or errors to raise by calling
{ClientStubs#stub_responses}. See {ClientStubs} for more information.

** Please note ** When response stubbing is enabled, no HTTP
requests are made, and retries are disabled.
        DOCS

      option(:region) do |config|
        'us-stubbed-1' if config.stub_responses
      end

      option(:credentials) do |config|
        if config.stub_responses
          Credentials.new('stubbed-akid', 'stubbed-secret')
        end
      end

      def add_handlers(handlers, config)
        handlers.add(Handler, step: :send) if config.stub_responses
      end

      def after_initialize(client)
        if client.config.stub_responses
          client.setup_stubbing
          client.handlers.remove(RetryErrors::Handler)
        end
      end

      class Handler < Seahorse::Client::Handler

        def call(context)
          stub = context.client.next_stub(context)
          resp = Seahorse::Client::Response.new(context: context)
          apply_stub(stub, resp)
          resp
        end

        def apply_stub(stub, response)
          http_resp = response.context.http_response
          case
          when stub[:error] then signal_error(stub[:error], http_resp)
          when stub[:http] then signal_http(stub[:http], http_resp)
          when stub[:data] then response.data = stub[:data]
          end
        end

        def signal_error(error, http_resp)
          if Exception === error
            http_resp.signal_error(error)
          else
            http_resp.signal_error(error.new)
          end
        end

        # @param [Seahorse::Client::Http::Response] stub
        # @param [Seahorse::Client::Http::Response] http_resp
        def signal_http(stub, http_resp)
          http_resp.signal_headers(stub.status_code, stub.headers.to_h)
          while chunk = stub.body.read(1024 * 1024)
            http_resp.signal_data(chunk)
          end
          stub.body.rewind
          http_resp.signal_done
        end

      end
    end
  end
end
