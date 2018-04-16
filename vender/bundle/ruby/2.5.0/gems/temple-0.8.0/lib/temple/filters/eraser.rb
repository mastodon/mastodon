module Temple
  module Filters
    # Erase expressions with a certain type
    #
    # @api public
    class Eraser < Filter
      # [] is the empty type => keep all
      define_options :erase, keep: [[]]

      def compile(exp)
        exp.first == :multi || (do?(:keep, exp) && !do?(:erase, exp)) ?
          super(exp) : [:multi]
      end

      protected

      def do?(list, exp)
        options[list].to_a.map {|type| [*type] }.any? {|type| exp[0,type.size] == type }
      end
    end
  end
end
