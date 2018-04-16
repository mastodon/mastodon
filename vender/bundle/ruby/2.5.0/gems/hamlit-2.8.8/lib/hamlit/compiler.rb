# frozen_string_literal: true
require 'hamlit/compiler/children_compiler'
require 'hamlit/compiler/comment_compiler'
require 'hamlit/compiler/doctype_compiler'
require 'hamlit/compiler/script_compiler'
require 'hamlit/compiler/silent_script_compiler'
require 'hamlit/compiler/tag_compiler'
require 'hamlit/filters'
require 'hamlit/identity'

module Hamlit
  class Compiler
    def initialize(options = {})
      identity                = Identity.new
      @children_compiler      = ChildrenCompiler.new
      @comment_compiler       = CommentCompiler.new
      @doctype_compiler       = DoctypeCompiler.new(options)
      @filter_compiler        = Filters.new(options)
      @script_compiler        = ScriptCompiler.new(identity)
      @silent_script_compiler = SilentScriptCompiler.new
      @tag_compiler           = TagCompiler.new(identity, options)
    end

    def call(ast)
      return runtime_error(ast) if ast.is_a?(HamlError)
      compile(ast)
    rescue Error => e
      runtime_error(e)
    end

    private

    def compile(node)
      case node.type
      when :root
        compile_children(node)
      when :comment
        compile_comment(node)
      when :doctype
        compile_doctype(node)
      when :filter
        compile_filter(node)
      when :plain
        compile_plain(node)
      when :script
        compile_script(node)
      when :silent_script
        compile_silent_script(node)
      when :tag
        compile_tag(node)
      when :haml_comment
        [:multi]
      else
        raise InternalError.new("Unexpected node type: #{node.type}")
      end
    end

    def compile_children(node)
      @children_compiler.compile(node) { |n| compile(n) }
    end

    def compile_comment(node)
      @comment_compiler.compile(node) { |n| compile_children(n) }
    end

    def compile_doctype(node)
      @doctype_compiler.compile(node)
    end

    def compile_filter(node)
      @filter_compiler.compile(node)
    end

    def compile_plain(node)
      [:static, node.value[:text]]
    end

    def compile_script(node)
      @script_compiler.compile(node) { |n| compile_children(n) }
    end

    def compile_silent_script(node)
      @silent_script_compiler.compile(node) { |n| compile_children(n) }
    end

    def compile_tag(node)
      @tag_compiler.compile(node) { |n| compile_children(n) }
    end

    def runtime_error(error)
      [:multi].tap do |temple|
        error.line.times { temple << [:newline] } if error.line
        temple << [:code, %Q[raise #{error.class}.new(%q[#{error.message}], #{error.line.inspect})]]
      end
    end
  end
end
