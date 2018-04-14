module Fog
  module Core
    module Utils
      # This helper prepares a Hash of settings for passing into {Fog::Service.new}.
      #
      # The only special consideration is if +:header+ key is passed in the contents are unchanged. This
      # allows the headers to be passed through to requests to customise HTTP headers without them being
      # broken by the +#to_sym+ calls.
      #
      # @param [Hash] settings The String based Hash to prepare
      # @option settings [Hash] :headers Passed to the underlying {Fog::Core::Connection} unchanged
      # @return [Hash]
      #
      def self.prepare_service_settings(settings)
        if settings.is_a? Hash
          copy = []
          settings.each do |key, value|
            obj = ![:headers].include?(key) ? prepare_service_settings(value) : value
            copy.push(key.to_sym, obj)
          end
          Hash[*copy]
        else
          settings
        end
      end
    end
  end
end
