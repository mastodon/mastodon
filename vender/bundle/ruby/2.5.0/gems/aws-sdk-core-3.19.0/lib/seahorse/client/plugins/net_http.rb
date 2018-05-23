require 'seahorse/client/net_http/handler'

module Seahorse
  module Client
    module Plugins
      class NetHttp < Plugin

        option(:http_proxy, default: nil, doc_type: String, docstring: '')

        option(:http_open_timeout, default: 15, doc_type: Integer, docstring: '')

        option(:http_read_timeout, default: 60, doc_type: Integer, docstring: '')

        option(:http_idle_timeout, default: 5, doc_type: Integer, docstring: '')

        option(:http_continue_timeout, default: 1, doc_type: Integer, docstring: '')

        option(:http_wire_trace, default: false, doc_type: 'Boolean', docstring: '')

        option(:ssl_verify_peer, default: true, doc_type: 'Boolean', docstring: '')

        option(:ssl_ca_bundle, default: nil, doc_type: String, docstring: '')

        option(:ssl_ca_directory, default: nil, doc_type: String, docstring: '')

        option(:ssl_ca_store, default: nil, doc_type: String, docstring: '')

        option(:logger) # for backwards compat

        handler(Client::NetHttp::Handler, step: :send)

      end
    end
  end
end
