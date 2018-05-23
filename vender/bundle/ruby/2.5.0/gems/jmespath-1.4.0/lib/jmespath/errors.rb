module JMESPath
  module Errors

    class Error < StandardError; end

    class RuntimeError < Error; end

    class SyntaxError < Error; end

    class InvalidTypeError < Error; end

    class InvalidValueError < Error; end

    class InvalidArityError < Error; end

    class UnknownFunctionError < Error; end

  end
end
