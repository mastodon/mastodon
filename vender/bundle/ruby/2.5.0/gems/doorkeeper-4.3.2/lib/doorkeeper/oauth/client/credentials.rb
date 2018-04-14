module Doorkeeper
  module OAuth
    class Client
      Credentials = Struct.new(:uid, :secret) do
        class << self
          def from_request(request, *credentials_methods)
            credentials_methods.inject(nil) do |credentials, method|
              method = self.method(method) if method.is_a?(Symbol)
              credentials = Credentials.new(*method.call(request))
              break credentials unless credentials.blank?
            end
          end

          def from_params(request)
            request.parameters.values_at(:client_id, :client_secret)
          end

          def from_basic(request)
            authorization = request.authorization
            if authorization.present? && authorization =~ /^Basic (.*)/m
              Base64.decode64(Regexp.last_match(1)).split(/:/, 2)
            end
          end
        end

        def blank?
          uid.blank? || secret.blank?
        end
      end
    end
  end
end
