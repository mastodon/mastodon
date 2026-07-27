# frozen_string_literal: true

module Vite
  module NameResolver
    def self.resolve(*names)
      add_base(*partial_resolve(*names))
    end

    def self.partial_resolve(*names)
      names.map do |name|
        # If the name is a single file we assume it is inside app/javascripts/entrypoints
        name.include?('/') ? name : "entrypoints/#{name}"
      end
    end

    def self.add_base(*names)
      names.map do |name|
        "#{Vite.config.base_path}#{name}"
      end
    end
  end
end
