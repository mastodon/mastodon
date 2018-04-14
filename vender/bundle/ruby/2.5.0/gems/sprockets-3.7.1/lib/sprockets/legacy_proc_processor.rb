require 'delegate'

module Sprockets
  # Deprecated: Wraps legacy process Procs with new processor call signature.
  #
  # Will be removed in Sprockets 4.x.
  #
  #     LegacyProcProcessor.new(:compress,
  #       proc { |context, data| data.gsub(...) })
  #
  class LegacyProcProcessor < Delegator
    def initialize(name, proc)
      @name = name
      @proc = proc
    end

    def __getobj__
      @proc
    end

    def name
      "Sprockets::LegacyProcProcessor (#{@name})"
    end

    def to_s
      name
    end

    def call(input)
      context = input[:environment].context_class.new(input)
      data = @proc.call(context, input[:data])
      context.metadata.merge(data: data.to_str)
    end
  end
end
