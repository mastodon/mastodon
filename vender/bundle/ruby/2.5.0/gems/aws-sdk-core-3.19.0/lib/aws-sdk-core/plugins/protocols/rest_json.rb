module Aws
  module Plugins
    module Protocols
      class RestJson < Seahorse::Client::Plugin

        handler(Rest::Handler)
        handler(Json::ErrorHandler, step: :sign)

      end
    end
  end
end
