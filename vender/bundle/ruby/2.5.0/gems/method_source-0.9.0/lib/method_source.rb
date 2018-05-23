# (C) John Mair (banisterfiend) 2011
# MIT License

direc = File.dirname(__FILE__)

require "#{direc}/method_source/version"
require "#{direc}/method_source/source_location"
require "#{direc}/method_source/code_helpers"

module MethodSource
  extend MethodSource::CodeHelpers

  # An Exception to mark errors that were raised trying to find the source from
  # a given source_location.
  #
  class SourceNotFoundError < StandardError; end

  # Helper method responsible for extracting method body.
  # Defined here to avoid polluting `Method` class.
  # @param [Array] source_location The array returned by Method#source_location
  # @param [String]  method_name
  # @return [String] The method body
  def self.source_helper(source_location, name=nil)
    raise SourceNotFoundError, "Could not locate source for #{name}!" unless source_location
    file, line = *source_location

    expression_at(lines_for(file), line)
  rescue SyntaxError => e
    raise SourceNotFoundError, "Could not parse source for #{name}: #{e.message}"
  end

  # Helper method responsible for opening source file and buffering up
  # the comments for a specified method. Defined here to avoid polluting
  # `Method` class.
  # @param [Array] source_location The array returned by Method#source_location
  # @param [String]  method_name
  # @return [String] The comments up to the point of the method.
  def self.comment_helper(source_location, name=nil)
    raise SourceNotFoundError, "Could not locate source for #{name}!" unless source_location
    file, line = *source_location

    comment_describing(lines_for(file), line)
  end

  # Load a memoized copy of the lines in a file.
  #
  # @param [String]  file_name
  # @param [String]  method_name
  # @return [Array<String>]  the contents of the file
  # @raise [SourceNotFoundError]
  def self.lines_for(file_name, name=nil)
    @lines_for_file ||= {}
    @lines_for_file[file_name] ||= File.readlines(file_name)
  rescue Errno::ENOENT => e
    raise SourceNotFoundError, "Could not load source for #{name}: #{e.message}"
  end

  # @deprecated — use MethodSource::CodeHelpers#complete_expression?
  def self.valid_expression?(str)
    complete_expression?(str)
  rescue SyntaxError
    false
  end

  # @deprecated — use MethodSource::CodeHelpers#expression_at
  def self.extract_code(source_location)
    source_helper(source_location)
  end

  # This module is to be included by `Method` and `UnboundMethod` and
  # provides the `#source` functionality
  module MethodExtensions

    # We use the included hook to patch Method#source on rubinius.
    # We need to use the included hook as Rubinius defines a `source`
    # on Method so including a module will have no effect (as it's
    # higher up the MRO).
    # @param [Class] klass The class that includes the module.
    def self.included(klass)
      if klass.method_defined?(:source) && Object.const_defined?(:RUBY_ENGINE) &&
          RUBY_ENGINE =~ /rbx/

        klass.class_eval do
          orig_source = instance_method(:source)

          define_method(:source) do
            begin
              super
            rescue
              orig_source.bind(self).call
            end
          end

        end
      end
    end

    # Return the sourcecode for the method as a string
    # @return [String] The method sourcecode as a string
    # @raise SourceNotFoundException
    #
    # @example
    #  Set.instance_method(:clear).source.display
    #  =>
    #     def clear
    #       @hash.clear
    #       self
    #     end
    def source
      MethodSource.source_helper(source_location, defined?(name) ? name : inspect)
    end

    # Return the comments associated with the method as a string.
    # @return [String] The method's comments as a string
    # @raise SourceNotFoundException
    #
    # @example
    #  Set.instance_method(:clear).comment.display
    #  =>
    #     # Removes all elements and returns self.
    def comment
      MethodSource.comment_helper(source_location, defined?(name) ? name : inspect)
    end
  end
end

class Method
  include MethodSource::SourceLocation::MethodExtensions
  include MethodSource::MethodExtensions
end

class UnboundMethod
  include MethodSource::SourceLocation::UnboundMethodExtensions
  include MethodSource::MethodExtensions
end

class Proc
  include MethodSource::SourceLocation::ProcExtensions
  include MethodSource::MethodExtensions
end

