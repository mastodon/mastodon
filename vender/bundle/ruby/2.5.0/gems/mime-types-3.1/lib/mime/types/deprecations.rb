# -*- ruby encoding: utf-8 -*-

require 'mime/types/logger'

# The namespace for MIME applications, tools, and libraries.
module MIME
  ##
  class Types
    # Used to mark a method as deprecated in the mime-types interface.
    def self.deprecated(klass, sym, message = nil, &block) # :nodoc:
      level = case klass
              when Class, Module
                '.'
              else
                klass = klass.class
                '#'
              end
      message = case message
                when :private, :protected
                  "and will be #{message}"
                when nil
                  'and will be removed'
                else
                  message
                end
      MIME::Types.logger.warn <<-warning.chomp
#{caller[1]}: #{klass}#{level}#{sym} is deprecated #{message}.
      warning
      block.call if block
    end
  end
end
