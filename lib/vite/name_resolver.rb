# frozen_string_literal: true

module Vite
  class NameResolver
    attr_reader :config

    def initialize(config:)
      @config = config
    end

    def full_path(name)
      bundle_path(entrypoint_path(name))
    end

    def entrypoint_path(name)
      # If the name is a single file we assume it is inside app/javascripts/entrypoints
      name.include?('/') ? name : "entrypoints/#{name}"
    end

    def bundle_path(name)
      "#{config.base_path}#{name}"
    end
  end
end
