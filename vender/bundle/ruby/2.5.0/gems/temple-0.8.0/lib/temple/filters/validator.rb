module Temple
  module Filters
    # Validates temple expression with given grammar
    #
    # @api public
    class Validator < Filter
      define_options grammar: Temple::Grammar

      def compile(exp)
        options[:grammar].validate!(exp)
        exp
      end
    end
  end
end
