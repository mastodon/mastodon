module Doorkeeper
  module OAuth
    module Helpers
      module ScopeChecker
        class Validator
          attr_reader :parsed_scopes, :scope_str

          def initialize(scope_str, server_scopes, application_scopes)
            @parsed_scopes = OAuth::Scopes.from_string(scope_str)
            @scope_str = scope_str
            @valid_scopes = valid_scopes(server_scopes, application_scopes)
          end

          def valid?
            scope_str.present? &&
              scope_str !~ /[\n\r\t]/ &&
              @valid_scopes.has_scopes?(parsed_scopes)
          end

          def match?
            valid? && parsed_scopes.has_scopes?(@valid_scopes)
          end

          private

          def valid_scopes(server_scopes, application_scopes)
            if application_scopes.present?
              application_scopes
            else
              server_scopes
            end
          end
        end

        def self.valid?(scope_str, server_scopes, application_scopes = nil)
          Validator.new(scope_str, server_scopes, application_scopes).valid?
        end

        def self.match?(scope_str, server_scopes, application_scopes = nil)
          Validator.new(scope_str, server_scopes, application_scopes).match?
        end
      end
    end
  end
end
