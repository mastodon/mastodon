require 'monitor'

module Tilt
  # Tilt::Mapping associates file extensions with template implementations.
  #
  #     mapping = Tilt::Mapping.new
  #     mapping.register(Tilt::RDocTemplate, 'rdoc')
  #     mapping['index.rdoc'] # => Tilt::RDocTemplate
  #     mapping.new('index.rdoc').render
  #
  # You can use {#register} to register a template class by file
  # extension, {#registered?} to see if a file extension is mapped,
  # {#[]} to lookup template classes, and {#new} to instantiate template
  # objects.
  #
  # Mapping also supports *lazy* template implementations. Note that regularly
  # registered template implementations *always* have preference over lazily
  # registered template implementations. You should use {#register} if you
  # depend on a specific template implementation and {#register_lazy} if there
  # are multiple alternatives.
  #
  #     mapping = Tilt::Mapping.new
  #     mapping.register_lazy('RDiscount::Template', 'rdiscount/template', 'md')
  #     mapping['index.md']
  #     # => RDiscount::Template
  #
  # {#register_lazy} takes a class name, a filename, and a list of file
  # extensions. When you try to lookup a template name that matches the
  # file extension, Tilt will automatically try to require the filename and
  # constantize the class name.
  #
  # Unlike {#register}, there can be multiple template implementations
  # registered lazily to the same file extension. Tilt will attempt to load the
  # template implementations in order (registered *last* would be tried first),
  # returning the first which doesn't raise LoadError.
  #
  # If all of the registered template implementations fails, Tilt will raise
  # the exception of the first, since that was the most preferred one.
  #
  #     mapping = Tilt::Mapping.new
  #     mapping.register_lazy('Bluecloth::Template', 'bluecloth/template', 'md')
  #     mapping.register_lazy('RDiscount::Template', 'rdiscount/template', 'md')
  #     mapping['index.md']
  #     # => RDiscount::Template
  #
  # In the previous example we say that RDiscount has a *higher priority* than
  # BlueCloth. Tilt will first try to `require "rdiscount/template"`, falling
  # back to `require "bluecloth/template"`. If none of these are successful,
  # the first error will be raised.
  class Mapping
    # @private
    attr_reader :lazy_map, :template_map

    def initialize
      @template_map = Hash.new
      @lazy_map = Hash.new { |h, k| h[k] = [] }
    end

    # @private
    def initialize_copy(other)
      @template_map = other.template_map.dup
      @lazy_map = other.lazy_map.dup
    end

    # Registers a lazy template implementation by file extension. You
    # can have multiple lazy template implementations defined on the
    # same file extension, in which case the template implementation
    # defined *last* will be attempted loaded *first*.
    #
    # @param class_name [String] Class name of a template class.
    # @param file [String] Filename where the template class is defined.
    # @param extensions [Array<String>] List of extensions.
    # @return [void]
    #
    # @example
    #   mapping.register_lazy 'MyEngine::Template', 'my_engine/template',  'mt'
    #
    #   defined?(MyEngine::Template) # => false
    #   mapping['index.mt'] # => MyEngine::Template
    #   defined?(MyEngine::Template) # => true
    def register_lazy(class_name, file, *extensions)
      # Internal API
      if class_name.is_a?(Symbol)
        Tilt.autoload class_name, file
        class_name = "Tilt::#{class_name}"
      end

      extensions.each do |ext|
        @lazy_map[ext].unshift([class_name, file])
      end
    end

    # Registers a template implementation by file extension. There can only be
    # one template implementation per file extension, and this method will
    # override any existing mapping.
    #
    # @param template_class
    # @param extensions [Array<String>] List of extensions.
    # @return [void]
    # 
    # @example
    #   mapping.register MyEngine::Template, 'mt'
    #   mapping['index.mt'] # => MyEngine::Template
    def register(template_class, *extensions)
      if template_class.respond_to?(:to_str)
        # Support register(ext, template_class) too
        extensions, template_class = [template_class], extensions[0]
      end

      extensions.each do |ext|
        @template_map[ext.to_s] = template_class
      end
    end

    # Checks if a file extension is registered (either eagerly or
    # lazily) in this mapping.
    #
    # @param ext [String] File extension.
    #
    # @example
    #   mapping.registered?('erb')  # => true
    #   mapping.registered?('nope') # => false
    def registered?(ext)
      @template_map.has_key?(ext.downcase) or lazy?(ext)
    end

    # Instantiates a new template class based on the file.
    #
    # @raise [RuntimeError] if there is no template class registered for the
    #   file name.
    #
    # @example
    #   mapping.new('index.mt') # => instance of MyEngine::Template
    #
    # @see Tilt::Template.new
    def new(file, line=nil, options={}, &block)
      if template_class = self[file]
        template_class.new(file, line, options, &block)
      else
        fail "No template engine registered for #{File.basename(file)}"
      end
    end

    # Looks up a template class based on file name and/or extension.
    #
    # @example
    #   mapping['views/hello.erb'] # => Tilt::ERBTemplate
    #   mapping['hello.erb']       # => Tilt::ERBTemplate
    #   mapping['erb']             # => Tilt::ERBTemplate
    #
    # @return [template class]
    def [](file)
      _, ext = split(file)
      ext && lookup(ext)
    end

    alias template_for []

    # Looks up a list of template classes based on file name. If the file name
    # has multiple extensions, it will return all template classes matching the
    # extensions from the end.
    #
    # @example
    #   mapping.templates_for('views/index.haml.erb')
    #   # => [Tilt::ERBTemplate, Tilt::HamlTemplate]
    #
    # @return [Array<template class>]
    def templates_for(file)
      templates = []

      while true
        prefix, ext = split(file)
        break unless ext
        templates << lookup(ext)
        file = prefix
      end

      templates
    end

    # Finds the extensions the template class has been registered under.
    # @param [template class] template_class
    def extensions_for(template_class)
      res = []
      template_map.each do |ext, klass|
        res << ext if template_class == klass
      end
      lazy_map.each do |ext, choices|
        res << ext if choices.any? { |klass, file| template_class.to_s == klass }
      end
      res
    end

    private

    def lazy?(ext)
      ext = ext.downcase
      @lazy_map.has_key?(ext) && !@lazy_map[ext].empty?
    end

    def split(file)
      pattern = file.to_s.downcase
      full_pattern = pattern.dup

      until registered?(pattern)
        return if pattern.empty?
        pattern = File.basename(pattern)
        pattern.sub!(/^[^.]*\.?/, '')
      end

      prefix_size = full_pattern.size - pattern.size
      [full_pattern[0,prefix_size-1], pattern]
    end

    def lookup(ext)
      @template_map[ext] || lazy_load(ext)
    end

    LOCK = Monitor.new

    def lazy_load(pattern)
      return unless @lazy_map.has_key?(pattern)

      LOCK.enter
      entered = true

      choices = @lazy_map[pattern]

      # Check if a template class is already present
      choices.each do |class_name, file|
        template_class = constant_defined?(class_name)
        if template_class
          register(template_class, pattern)
          return template_class
        end
      end

      first_failure = nil

      # Load in order
      choices.each do |class_name, file|
        begin
          require file
          # It's safe to eval() here because constant_defined? will
          # raise NameError on invalid constant names
          template_class = eval(class_name)
        rescue LoadError => ex
          first_failure ||= ex
        else
          register(template_class, pattern)
          return template_class
        end
      end

      raise first_failure if first_failure
    ensure
      LOCK.exit if entered
    end

    # This is due to a bug in JRuby (see GH issue jruby/jruby#3585)
    Tilt.autoload :Dummy, "tilt/dummy"
    require "tilt/dummy"
    AUTOLOAD_IS_BROKEN = Tilt.autoload?(:Dummy)

    # The proper behavior (in MRI) for autoload? is to
    # return `false` when the constant/file has been
    # explicitly required.
    #
    # However, in JRuby it returns `true` even after it's
    # been required. In that case it turns out that `defined?`
    # returns `"constant"` if it exists and `nil` when it doesn't.
    # This is actually a second bug: `defined?` should resolve
    # autoload (aka. actually try to require the file).
    #
    # We use the second bug in order to resolve the first bug.

    def constant_defined?(name)
      name.split('::').inject(Object) do |scope, n|
        if scope.autoload?(n)
          if !AUTOLOAD_IS_BROKEN
            return false
          end

          if eval("!defined?(scope::#{n})")
            return false
          end
        end
        return false if !scope.const_defined?(n)
        scope.const_get(n)
      end
    end
  end
end
