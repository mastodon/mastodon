# frozen_string_literal: true
module Hamlit
  class Compiler
    class ChildrenCompiler
      def initialize
        @lineno = 1
      end

      def compile(node, &block)
        temple = [:multi]
        return temple if node.children.empty?

        temple << :whitespace if prepend_whitespace?(node)
        node.children.each do |n|
          rstrip_whitespace!(temple) if nuke_prev_whitespace?(n)
          insert_newlines!(temple, n)
          temple << yield(n)
          temple << :whitespace if insert_whitespace?(n)
        end
        rstrip_whitespace!(temple) if nuke_inner_whitespace?(node)
        confirm_whitespace(temple)
      end

      private

      def insert_newlines!(temple, node)
        (node.line - @lineno).times do
          temple << [:newline]
        end
        @lineno = node.line

        case node.type
        when :script, :silent_script
          @lineno += 1
        when :filter
          @lineno += (node.value[:text] || '').split("\n").size
        when :tag
          node.value[:attributes_hashes].each do |attribute_hash|
            @lineno += attribute_hash.count("\n")
          end
          @lineno += 1 if node.children.empty? && node.value[:parse]
        end
      end

      def confirm_whitespace(temple)
        temple.map do |exp|
          case exp
          when :whitespace
            [:static, "\n"]
          else
            exp
          end
        end
      end

      def prepend_whitespace?(node)
        return false unless %i[comment tag].include?(node.type)
        !nuke_inner_whitespace?(node)
      end

      def nuke_inner_whitespace?(node)
        case
        when node.type == :tag
          node.value[:nuke_inner_whitespace]
        when node.parent.nil?
          false
        else
          nuke_inner_whitespace?(node.parent)
        end
      end

      def nuke_prev_whitespace?(node)
        case node.type
        when :tag
          node.value[:nuke_outer_whitespace]
        when :silent_script
          !node.children.empty? && nuke_prev_whitespace?(node.children.first)
        else
          false
        end
      end

      def nuke_outer_whitespace?(node)
        return false if node.type != :tag
        node.value[:nuke_outer_whitespace]
      end

      def rstrip_whitespace!(temple)
        if temple[-1] == :whitespace
          temple.delete_at(-1)
        end
      end

      def insert_whitespace?(node)
        return false if nuke_outer_whitespace?(node)

        case node.type
        when :doctype
          node.value[:type] != 'xml'
        when :comment, :plain, :tag
          true
        when :script
          node.children.empty? && !nuke_inner_whitespace?(node)
        when :filter
          !%w[ruby].include?(node.value[:name])
        else
          false
        end
      end
    end
  end
end
