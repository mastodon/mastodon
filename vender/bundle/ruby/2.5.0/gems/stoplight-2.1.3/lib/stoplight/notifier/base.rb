# coding: utf-8

module Stoplight
  module Notifier
    # @abstract
    class Base
      # @param _light [Light]
      # @param _from_color [String]
      # @param _to_color [String]
      # @param _error [Exception, nil]
      # @return [String]
      def notify(_light, _from_color, _to_color, _error)
        raise NotImplementedError
      end
    end
  end
end
