require 'delegate'

module Sprockets
  # Deprecated: Wraps legacy engine and process Tilt templates with new
  # processor call signature.
  #
  # Will be removed in Sprockets 4.x.
  #
  #     LegacyTiltProcessor.new(Tilt::CoffeeScriptProcessor)
  #
  class LegacyTiltProcessor < Delegator
    def initialize(klass)
      @klass = klass
    end

    def __getobj__
      @klass
    end

    def call(input)
      filename = input[:filename]
      data     = input[:data]
      context  = input[:environment].context_class.new(input)

      data = @klass.new(filename) { data }.render(context, {})
      context.metadata.merge(data: data.to_str)
    end
  end
end
