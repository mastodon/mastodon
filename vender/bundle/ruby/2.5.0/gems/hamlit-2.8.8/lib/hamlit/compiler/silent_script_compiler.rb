# frozen_string_literal: true
module Hamlit
  class Compiler
    class SilentScriptCompiler
      def compile(node, &block)
        if node.children.empty?
          [:multi, [:code, node.value[:text]], [:newline]]
        else
          compile_with_children(node, &block)
        end
      end

      private

      def compile_with_children(node, &block)
        [:multi,
         [:block, node.value[:text],
          [:multi, [:newline], yield(node)],
         ],
        ]
      end
    end
  end
end
