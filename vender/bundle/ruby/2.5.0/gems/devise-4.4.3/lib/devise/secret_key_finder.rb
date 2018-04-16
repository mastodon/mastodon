# frozen_string_literal: true

module Devise
  class SecretKeyFinder
    def initialize(application)
      @application = application
    end

    def find
      if @application.respond_to?(:credentials) && key_exists?(@application.credentials)
        @application.credentials.secret_key_base
      elsif @application.respond_to?(:secrets) && key_exists?(@application.secrets)
        @application.secrets.secret_key_base
      elsif @application.config.respond_to?(:secret_key_base) && key_exists?(@application.config)
        @application.config.secret_key_base
      end
    end

    private

    def key_exists?(object)
      object.secret_key_base.present?
    end
  end
end
