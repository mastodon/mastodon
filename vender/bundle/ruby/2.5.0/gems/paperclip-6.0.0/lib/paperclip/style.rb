# encoding: utf-8
module Paperclip
  # The Style class holds the definition of a thumbnail style,  applying
  # whatever processing is required to normalize the definition and delaying
  # the evaluation of block parameters until useful context is available.

  class Style

    attr_reader :name, :attachment, :format

    # Creates a Style object. +name+ is the name of the attachment,
    # +definition+ is the style definition from has_attached_file, which
    # can be string, array or hash
    def initialize name, definition, attachment
      @name = name
      @attachment = attachment
      if definition.is_a? Hash
        @geometry = definition.delete(:geometry)
        @format = definition.delete(:format)
        @processors = definition.delete(:processors)
        @convert_options = definition.delete(:convert_options)
        @source_file_options = definition.delete(:source_file_options)
        @other_args = definition
      elsif definition.is_a? String
        @geometry = definition
        @format = nil
        @other_args = {}
      else
        @geometry, @format = [definition, nil].flatten[0..1]
        @other_args = {}
      end
      @format = default_format if @format.blank?
    end

    # retrieves from the attachment the processors defined in the has_attached_file call
    # (which method (in the attachment) will call any supplied procs)
    # There is an important change of interface here: a style rule can set its own processors
    # by default we behave as before, though.
    # if a proc has been supplied, we call it here
    def processors
      @processors.respond_to?(:call) ? @processors.call(attachment.instance) : (@processors || attachment.processors)
    end

    # retrieves from the attachment the whiny setting
    def whiny
      attachment.whiny
    end

    # returns true if we're inclined to grumble
    def whiny?
      !!whiny
    end

    def convert_options
      @convert_options.respond_to?(:call) ? @convert_options.call(attachment.instance) :
        (@convert_options || attachment.send(:extra_options_for, name))
    end

    def source_file_options
      @source_file_options.respond_to?(:call) ? @source_file_options.call(attachment.instance) :
        (@source_file_options || attachment.send(:extra_source_file_options_for, name))
    end

    # returns the geometry string for this style
    # if a proc has been supplied, we call it here
    def geometry
      @geometry.respond_to?(:call) ? @geometry.call(attachment.instance) : @geometry
    end

    # Supplies the hash of options that processors expect to receive as their second argument
    # Arguments other than the standard geometry, format etc are just passed through from
    # initialization and any procs are called here, just before post-processing.
    def processor_options
      args = {:style => name}
      @other_args.each do |k,v|
        args[k] = v.respond_to?(:call) ? v.call(attachment) : v
      end
      [:processors, :geometry, :format, :whiny, :convert_options, :source_file_options].each do |k|
        (arg = send(k)) && args[k] = arg
      end
      args
    end

    # Supports getting and setting style properties with hash notation to ensure backwards-compatibility
    # eg. @attachment.styles[:large][:geometry]@ will still work
    def [](key)
      if [:name, :convert_options, :whiny, :processors, :geometry, :format, :animated, :source_file_options].include?(key)
        send(key)
      elsif defined? @other_args[key]
        @other_args[key]
      end
    end

    def []=(key, value)
      if [:name, :convert_options, :whiny, :processors, :geometry, :format, :animated, :source_file_options].include?(key)
        send("#{key}=".intern, value)
      else
        @other_args[key] = value
      end
    end

    # defaults to default format (nil by default)
    def default_format
      base = attachment.options[:default_format]
      base.respond_to?(:call) ? base.call(attachment, name) : base
    end

  end
end
