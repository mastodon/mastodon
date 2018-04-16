begin
  require 'rails/railtie'

  module Hashie
    class Railtie < Rails::Railtie
      # Set the Hashie.logger to use Rails.logger when used with rails.
      initializer 'hashie.configure_logger', after: 'initialize_logger' do
        Hashie.logger = Rails.logger
      end
    end
  end
rescue LoadError => e
  Hashie.logger.info("Hashie skipping railtie as #{e.message}")
end
