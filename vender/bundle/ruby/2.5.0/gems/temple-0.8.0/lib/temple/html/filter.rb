module Temple
  module HTML
    # @api public
    class Filter < Temple::Filter
      include Dispatcher

      def contains_nonempty_static?(exp)
        case exp.first
        when :multi
          exp[1..-1].any? {|e| contains_nonempty_static?(e) }
        when :escape
          contains_nonempty_static?(exp.last)
        when :static
          !exp.last.empty?
        else
          false
        end
      end
    end
  end
end
