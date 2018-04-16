module Aws
  module Plugins
    module Protocols
      class RestXml < Seahorse::Client::Plugin

        handler(Rest::Handler)
        handler(Xml::ErrorHandler, step: :sign)

      end
    end
  end
end
