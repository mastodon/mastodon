require_relative '../../query'

module Aws
  module Plugins
    module Protocols
      class Query < Seahorse::Client::Plugin
        handler(Aws::Query::Handler)
        handler(Xml::ErrorHandler, step: :sign)
      end
    end
  end
end
