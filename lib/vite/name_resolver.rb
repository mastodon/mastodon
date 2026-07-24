# frozen_string_literal: true

module Vite
  class NameResolver
    def self.resolve(*names)
      new.resolve(*names)
    end

    def resolve(*names)
      names.map do |name|
        # If the name is a single file we assume it is inside app/javascripts/entrypoints
        resolved = name.include?('/') ? name : "entrypoints/#{name}"
        "#{Vite.config.base_path}#{resolved}"
      end
    end
  end
end
