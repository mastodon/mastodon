require 'yaml'

module Puma
  class StateFile
    def initialize
      @options = {}
    end

    def save(path)
      File.write path, YAML.dump(@options)
    end

    def load(path)
      @options = YAML.load File.read(path)
    end

    FIELDS = %w!control_url control_auth_token pid!

    FIELDS.each do |f|
      define_method f do
        @options[f]
      end

      define_method "#{f}=" do |v|
        @options[f] = v
      end
    end
  end
end
