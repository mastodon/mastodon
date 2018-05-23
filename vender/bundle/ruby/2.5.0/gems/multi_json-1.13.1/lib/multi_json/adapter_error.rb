module MultiJson
  class AdapterError < ArgumentError
    attr_reader :cause

    def self.build(original_exception)
      message = "Did not recognize your adapter specification (#{original_exception.message})."
      new(message).tap do |exception|
        exception.instance_eval do
          @cause = original_exception
          set_backtrace original_exception.backtrace
        end
      end
    end
  end
end
