module Nokogiri
  module CSS
    class XPathVisitor # :nodoc:
      def visit_function node

        msg = :"visit_function_#{node.value.first.gsub(/[(]/, '')}"
        return self.send(msg, node) if self.respond_to?(msg)

        case node.value.first
        when /^text\(/
          'child::text()'
        when /^self\(/
          "self::#{node.value[1]}"
        when /^eq\(/
          "position() = #{node.value[1]}"
        when /^(nth|nth-of-type)\(/
          if node.value[1].is_a?(Nokogiri::CSS::Node) and node.value[1].type == :NTH
            nth(node.value[1])
          else
            "position() = #{node.value[1]}"
          end
        when /^nth-child\(/
          if node.value[1].is_a?(Nokogiri::CSS::Node) and node.value[1].type == :NTH
            nth(node.value[1], :child => true)
          else
            "count(preceding-sibling::*) = #{node.value[1].to_i-1}"
          end
        when /^nth-last-of-type\(/
          if node.value[1].is_a?(Nokogiri::CSS::Node) and node.value[1].type == :NTH
            nth(node.value[1], :last => true)
          else
            index = node.value[1].to_i - 1
            index == 0 ? "position() = last()" : "position() = last() - #{index}"
          end
        when /^nth-last-child\(/
          if node.value[1].is_a?(Nokogiri::CSS::Node) and node.value[1].type == :NTH
            nth(node.value[1], :last => true, :child => true)
          else
            "count(following-sibling::*) = #{node.value[1].to_i-1}"
          end
        when /^(first|first-of-type)\(/
          "position() = 1"
        when /^(last|last-of-type)\(/
          "position() = last()"
        when /^contains\(/
          "contains(., #{node.value[1]})"
        when /^gt\(/
          "position() > #{node.value[1]}"
        when /^only-child\(/
          "last() = 1"
        when /^comment\(/
          "comment()"
        when /^has\(/
          node.value[1].accept(self)
        else
          args = ['.'] + node.value[1..-1]
          "#{node.value.first}#{args.join(', ')})"
        end
      end

      def visit_not node
        child = node.value.first
        if :ELEMENT_NAME == child.type
          "not(self::#{child.accept(self)})"
        else
          "not(#{child.accept(self)})"
        end
      end

      def visit_id node
        node.value.first =~ /^#(.*)$/
        "@id = '#{$1}'"
      end

      def visit_attribute_condition node
         attribute = if (node.value.first.type == :FUNCTION) or (node.value.first.value.first =~ /::/)
                       ''
                     else
                       '@'
                     end
        attribute += node.value.first.accept(self)

        # Support non-standard css
        attribute.gsub!(/^@@/, '@')

        return attribute unless node.value.length == 3

        value = node.value.last
        value = "'#{value}'" if value !~ /^['"]/

        case node.value[1]
        when :equal
          attribute + " = " + "#{value}"
        when :not_equal
          attribute + " != " + "#{value}"
        when :substring_match
          "contains(#{attribute}, #{value})"
        when :prefix_match
          "starts-with(#{attribute}, #{value})"
        when :dash_match
          "#{attribute} = #{value} or starts-with(#{attribute}, concat(#{value}, '-'))"
        when :includes
          "contains(concat(\" \", #{attribute}, \" \"),concat(\" \", #{value}, \" \"))"
        when :suffix_match
          "substring(#{attribute}, string-length(#{attribute}) - " +
            "string-length(#{value}) + 1, string-length(#{value})) = #{value}"
        else
          attribute + " #{node.value[1]} " + "#{value}"
        end
      end

      def visit_pseudo_class node
        if node.value.first.is_a?(Nokogiri::CSS::Node) and node.value.first.type == :FUNCTION
          node.value.first.accept(self)
        else
          msg = :"visit_pseudo_class_#{node.value.first.gsub(/[(]/, '')}"
          return self.send(msg, node) if self.respond_to?(msg)

          case node.value.first
          when "first" then "position() = 1"
          when "first-child" then "count(preceding-sibling::*) = 0"
          when "last" then "position() = last()"
          when "last-child" then "count(following-sibling::*) = 0"
          when "first-of-type" then "position() = 1"
          when "last-of-type" then "position() = last()"
          when "only-child" then "count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0"
          when "only-of-type" then "last() = 1"
          when "empty" then "not(node())"
          when "parent" then "node()"
          when "root" then "not(parent::*)"
          else
            node.value.first + "(.)"
          end
        end
      end

      def visit_class_condition node
        "contains(concat(' ', normalize-space(@class), ' '), ' #{node.value.first} ')"
      end

      def visit_combinator node
        if is_of_type_pseudo_class?(node.value.last)
          "#{node.value.first.accept(self) if node.value.first}][#{node.value.last.accept(self)}"
        else
          "#{node.value.first.accept(self) if node.value.first} and #{node.value.last.accept(self)}"
        end
      end
      
      {
        'direct_adjacent_selector'  => "/following-sibling::*[1]/self::",
        'following_selector'        => "/following-sibling::",
        'descendant_selector'       => '//',
        'child_selector'            => '/',
      }.each do |k,v|
        class_eval %{
          def visit_#{k} node
            "\#{node.value.first.accept(self) if node.value.first}#{v}\#{node.value.last.accept(self)}"
          end
        }
      end

      def visit_conditional_selector node
        node.value.first.accept(self) + '[' +
        node.value.last.accept(self) + ']'
      end

      def visit_element_name node
        node.value.first
      end

      def accept node
        node.accept(self)
      end

    private
      def nth node, options={}
        raise ArgumentError, "expected an+b node to contain 4 tokens, but is #{node.value.inspect}" unless node.value.size == 4

        a, b = read_a_and_positive_b node.value
        position = if options[:child]
          options[:last] ? "(count(following-sibling::*) + 1)" : "(count(preceding-sibling::*) + 1)"
        else
          options[:last] ? "(last()-position()+1)" : "position()"
        end

        if b.zero?
          "(#{position} mod #{a}) = 0"
        else
          compare = a < 0 ? "<=" : ">="
          if a.abs == 1
            "#{position} #{compare} #{b}"
          else
            "(#{position} #{compare} #{b}) and (((#{position}-#{b}) mod #{a.abs}) = 0)"
          end
        end
      end

      def read_a_and_positive_b values
        op = values[2]
        if op == "+"
          a = values[0].to_i
          b = values[3].to_i
        elsif op == "-"
          a = values[0].to_i
          b = a - (values[3].to_i % a)
        else
          raise ArgumentError, "expected an+b node to have either + or - as the operator, but is #{op.inspect}"
        end
        [a, b]
      end
      
      def is_of_type_pseudo_class? node
        if node.type==:PSEUDO_CLASS
          if node.value[0].is_a?(Nokogiri::CSS::Node) and node.value[0].type == :FUNCTION
            node.value[0].value[0]
          else
            node.value[0]
          end =~ /(nth|first|last|only)-of-type(\()?/
        end   
      end
    end
  end
end
