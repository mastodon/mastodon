module Doorkeeper
  module Rails
    class Routes # :nodoc:
      class Mapping
        attr_accessor :controllers, :as, :skips

        def initialize
          @controllers = {
            authorizations: 'doorkeeper/authorizations',
            applications: 'doorkeeper/applications',
            authorized_applications: 'doorkeeper/authorized_applications',
            tokens: 'doorkeeper/tokens',
            token_info: 'doorkeeper/token_info'
          }

          @as = {
            authorizations: :authorization,
            tokens: :token,
            token_info: :token_info
          }

          @skips = []
        end

        def [](routes)
          {
            controllers: @controllers[routes],
            as: @as[routes]
          }
        end

        def skipped?(controller)
          @skips.include?(controller)
        end
      end
    end
  end
end
