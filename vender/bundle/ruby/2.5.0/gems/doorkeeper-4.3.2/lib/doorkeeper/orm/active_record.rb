require 'active_support/lazy_load_hooks'

module Doorkeeper
  module Orm
    module ActiveRecord
      def self.initialize_models!
        lazy_load do
          require 'doorkeeper/orm/active_record/access_grant'
          require 'doorkeeper/orm/active_record/access_token'
          require 'doorkeeper/orm/active_record/application'

          if Doorkeeper.configuration.active_record_options[:establish_connection]
            [Doorkeeper::AccessGrant, Doorkeeper::AccessToken, Doorkeeper::Application].each do |model|
              options = Doorkeeper.configuration.active_record_options[:establish_connection]
              model.establish_connection(options)
            end
          end
        end
      end

      def self.initialize_application_owner!
        lazy_load do
          require 'doorkeeper/models/concerns/ownership'

          Doorkeeper::Application.send :include, Doorkeeper::Models::Ownership
        end
      end

      def self.lazy_load(&block)
        ActiveSupport.on_load(:active_record, {}, &block)
      end
    end
  end
end
