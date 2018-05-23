# frozen_string_literal: true
require 'hamlit/ruby_expression'
require 'hamlit/string_splitter'

module Hamlit
  class Compiler
    class ScriptCompiler
      def initialize(identity)
        @identity = identity
      end

      def compile(node, &block)
        no_children = node.children.empty?
        case
        when no_children && node.value[:escape_interpolation]
          compile_interpolated_plain(node)
        when no_children && RubyExpression.string_literal?(node.value[:text])
          delegate_optimization(node)
        when no_children && Temple::StaticAnalyzer.static?(node.value[:text])
          static_compile(node)
        else
          dynamic_compile(node, &block)
        end
      end

      private

      # String-interpolated plain text must be compiled with this method
      # because we have to escape only interpolated values.
      def compile_interpolated_plain(node)
        temple = [:multi]
        StringSplitter.compile(node.value[:text]).each do |type, value|
          case type
          when :static
            temple << [:static, value]
          when :dynamic
            temple << [:escape, node.value[:escape_interpolation], [:dynamic, value]]
          end
        end
        temple << [:newline]
      end

      # :dynamic is optimized in other filter: StringSplitter
      def delegate_optimization(node)
        [:multi,
         [:escape, node.value[:escape_html], [:dynamic, node.value[:text]]],
         [:newline],
        ]
      end

      def static_compile(node)
        str = eval(node.value[:text]).to_s
        if node.value[:escape_html]
          str = Hamlit::Utils.escape_html(str)
        elsif node.value[:preserve]
          str = ::Hamlit::HamlHelpers.find_and_preserve(str, %w(textarea pre code))
        end
        [:multi, [:static, str], [:newline]]
      end

      def dynamic_compile(node, &block)
        var = @identity.generate
        temple = compile_script_assign(var, node, &block)
        temple << compile_script_result(var, node)
      end

      def compile_script_assign(var, node, &block)
        if node.children.empty?
          [:multi,
           [:code, "#{var} = (#{node.value[:text]}"],
           [:newline],
           [:code, ')'],
          ]
        else
          [:multi,
           [:block, "#{var} = #{node.value[:text]}",
            [:multi, [:newline], yield(node)],
           ],
          ]
        end
      end

      def compile_script_result(result, node)
        if !node.value[:escape_html] && node.value[:preserve]
          result = find_and_preserve(result)
        else
          result = "(#{result}).to_s"
        end
        [:escape, node.value[:escape_html], [:dynamic, result]]
      end

      def find_and_preserve(code)
        %Q[::Hamlit::HamlHelpers.find_and_preserve(#{code}, %w(textarea pre code))]
      end

      def escape_html(temple)
        [:escape, true, temple]
      end
    end
  end
end
