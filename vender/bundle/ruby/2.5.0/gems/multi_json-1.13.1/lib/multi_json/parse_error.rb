module MultiJson
  class ParseError < StandardError
    attr_reader :data, :cause

    def self.build(original_exception, data)
      new(original_exception.message).tap do |exception|
        exception.instance_eval do
          @cause = original_exception
          set_backtrace original_exception.backtrace
          @data = data
        end
      end
    end
  end

  DecodeError = LoadError = ParseError # Legacy support
end
