require 'singleton'

module Paperclip
  class AttachmentRegistry
    include Singleton

    def self.register(klass, attachment_name, attachment_options)
      instance.register(klass, attachment_name, attachment_options)
    end

    def self.clear
      instance.clear
    end

    def self.names_for(klass)
      instance.names_for(klass)
    end

    def self.each_definition(&block)
      instance.each_definition(&block)
    end

    def self.definitions_for(klass)
      instance.definitions_for(klass)
    end

    def initialize
      clear
    end

    def register(klass, attachment_name, attachment_options)
      @attachments ||= {}
      @attachments[klass] ||= {}
      @attachments[klass][attachment_name] = attachment_options
    end

    def clear
      @attachments = Hash.new { |h,k| h[k] = {} }
    end

    def names_for(klass)
      @attachments[klass].keys
    end

    def each_definition
      @attachments.each do |klass, attachments|
        attachments.each do |name, options|
          yield klass, name, options
        end
      end
    end

    def definitions_for(klass)
      parent_classes = klass.ancestors.reverse
      parent_classes.each_with_object({}) do |ancestor, inherited_definitions|
        inherited_definitions.deep_merge! @attachments[ancestor]
      end
    end
  end
end
