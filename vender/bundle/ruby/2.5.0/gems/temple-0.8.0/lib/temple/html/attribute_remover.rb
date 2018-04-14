module Temple
  module HTML
    # This filter removes empty attributes
    # @api public
    class AttributeRemover < Filter
      define_options remove_empty_attrs: %w(id class)

      def initialize(opts = {})
        super
        raise ArgumentError, "Option :remove_empty_attrs must be an Array of Strings" unless Array === options[:remove_empty_attrs] &&
          options[:remove_empty_attrs].all? {|a| String === a }
      end

      def on_html_attrs(*attrs)
        [:multi, *attrs.map {|attr| compile(attr) }]
      end

      def on_html_attr(name, value)
        return super unless options[:remove_empty_attrs].include?(name.to_s)

        if empty_exp?(value)
          value
        elsif contains_nonempty_static?(value)
          [:html, :attr, name, value]
        else
          tmp = unique_name
          [:multi,
           [:capture, tmp, compile(value)],
           [:if, "!#{tmp}.empty?",
            [:html, :attr, name, [:dynamic, tmp]]]]
        end
      end
    end
  end
end
