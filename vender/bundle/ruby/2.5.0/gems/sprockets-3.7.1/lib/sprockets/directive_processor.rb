require 'set'
require 'shellwords'

module Sprockets
  # The `DirectiveProcessor` is responsible for parsing and evaluating
  # directive comments in a source file.
  #
  # A directive comment starts with a comment prefix, followed by an "=",
  # then the directive name, then any arguments.
  #
  #     // JavaScript
  #     //= require "foo"
  #
  #     # CoffeeScript
  #     #= require "bar"
  #
  #     /* CSS
  #      *= require "baz"
  #      */
  #
  # This makes it possible to disable or modify the processor to do whatever
  # you'd like. You could add your own custom directives or invent your own
  # directive syntax.
  #
  # `Environment#processors` includes `DirectiveProcessor` by default.
  #
  # To remove the processor entirely:
  #
  #     env.unregister_processor('text/css', Sprockets::DirectiveProcessor)
  #     env.unregister_processor('application/javascript', Sprockets::DirectiveProcessor)
  #
  # Then inject your own preprocessor:
  #
  #     env.register_processor('text/css', MyProcessor)
  #
  class DirectiveProcessor
    VERSION = '1'

    # Directives are denoted by a `=` followed by the name, then
    # argument list.
    #
    # A few different styles are allowed:
    #
    #     // =require foo
    #     //= require foo
    #     //= require "foo"
    #
    DIRECTIVE_PATTERN = /
      ^ \W* = \s* (\w+.*?) (\*\/)? $
    /x

    def self.instance
      @instance ||= new(
        # Deprecated: Default to C and Ruby comment styles
        comments: ["//", ["/*", "*/"]] + ["#", ["###", "###"]]
      )
    end

    def self.call(input)
      instance.call(input)
    end

    def initialize(options = {})
      @header_pattern = compile_header_pattern(Array(options[:comments]))
    end

    def call(input)
      dup._call(input)
    end

    def _call(input)
      @environment  = input[:environment]
      @uri          = input[:uri]
      @filename     = input[:filename]
      @dirname      = File.dirname(@filename)
      @content_type = input[:content_type]
      @required     = Set.new(input[:metadata][:required])
      @stubbed      = Set.new(input[:metadata][:stubbed])
      @links        = Set.new(input[:metadata][:links])
      @dependencies = Set.new(input[:metadata][:dependencies])

      data, directives = process_source(input[:data])
      process_directives(directives)

      { data: data,
        required: @required,
        stubbed: @stubbed,
        links: @links,
        dependencies: @dependencies }
    end

    protected
      # Directives will only be picked up if they are in the header
      # of the source file. C style (/* */), JavaScript (//), and
      # Ruby (#) comments are supported.
      #
      # Directives in comments after the first non-whitespace line
      # of code will not be processed.
      def compile_header_pattern(comments)
        re = comments.map { |c|
          case c
          when String
            "(?:#{Regexp.escape(c)}.*\\n?)+"
          when Array
            "(?:#{Regexp.escape(c[0])}(?m:.*?)#{Regexp.escape(c[1])})"
          else
            raise TypeError, "unknown comment type: #{c.class}"
          end
        }.join("|")
        Regexp.compile("\\A(?:(?m:\\s*)(?:#{re}))+")
      end

      def process_source(source)
        header = source[@header_pattern, 0] || ""
        body   = $' || source

        header, directives = extract_directives(header)

        data = ""
        data.force_encoding(body.encoding)
        data << header << "\n" unless header.empty?
        data << body
        # Ensure body ends in a new line
        data << "\n" if data.length > 0 && data[-1] != "\n"

        return data, directives
      end

      # Returns an Array of directive structures. Each structure
      # is an Array with the line number as the first element, the
      # directive name as the second element, followed by any
      # arguments.
      #
      #     [[1, "require", "foo"], [2, "require", "bar"]]
      #
      def extract_directives(header)
        processed_header = ""
        directives = []

        header.lines.each_with_index do |line, index|
          if directive = line[DIRECTIVE_PATTERN, 1]
            name, *args = Shellwords.shellwords(directive)
            if respond_to?("process_#{name}_directive", true)
              directives << [index + 1, name, *args]
              # Replace directive line with a clean break
              line = "\n"
            end
          end
          processed_header << line
        end

        return processed_header.chomp, directives
      end

      # Gathers comment directives in the source and processes them.
      # Any directive method matching `process_*_directive` will
      # automatically be available. This makes it easy to extend the
      # processor.
      #
      # To implement a custom directive called `require_glob`, subclass
      # `Sprockets::DirectiveProcessor`, then add a method called
      # `process_require_glob_directive`.
      #
      #     class DirectiveProcessor < Sprockets::DirectiveProcessor
      #       def process_require_glob_directive
      #         Dir["#{dirname}/#{glob}"].sort.each do |filename|
      #           require(filename)
      #         end
      #       end
      #     end
      #
      # Replace the current processor on the environment with your own:
      #
      #     env.unregister_processor('text/css', Sprockets::DirectiveProcessor)
      #     env.register_processor('text/css', DirectiveProcessor)
      #
      def process_directives(directives)
        directives.each do |line_number, name, *args|
          begin
            send("process_#{name}_directive", *args)
          rescue Exception => e
            e.set_backtrace(["#{@filename}:#{line_number}"] + e.backtrace)
            raise e
          end
        end
      end

      # The `require` directive functions similar to Ruby's own `require`.
      # It provides a way to declare a dependency on a file in your path
      # and ensures its only loaded once before the source file.
      #
      # `require` works with files in the environment path:
      #
      #     //= require "foo.js"
      #
      # Extensions are optional. If your source file is ".js", it
      # assumes you are requiring another ".js".
      #
      #     //= require "foo"
      #
      # Relative paths work too. Use a leading `./` to denote a relative
      # path:
      #
      #     //= require "./bar"
      #
      def process_require_directive(path)
        @required << resolve(path, accept: @content_type, pipeline: :self)
      end

      # `require_self` causes the body of the current file to be inserted
      # before any subsequent `require` directives. Useful in CSS files, where
      # it's common for the index file to contain global styles that need to
      # be defined before other dependencies are loaded.
      #
      #     /*= require "reset"
      #      *= require_self
      #      *= require_tree .
      #      */
      #
      def process_require_self_directive
        if @required.include?(@uri)
          raise ArgumentError, "require_self can only be called once per source file"
        end
        @required << @uri
      end

      # `require_directory` requires all the files inside a single
      # directory. It's similar to `path/*` since it does not follow
      # nested directories.
      #
      #     //= require_directory "./javascripts"
      #
      def process_require_directory_directive(path = ".")
        path = expand_relative_dirname(:require_directory, path)
        require_paths(*@environment.stat_directory_with_dependencies(path))
      end

      # `require_tree` requires all the nested files in a directory.
      # Its glob equivalent is `path/**/*`.
      #
      #     //= require_tree "./public"
      #
      def process_require_tree_directive(path = ".")
        path = expand_relative_dirname(:require_tree, path)
        require_paths(*@environment.stat_sorted_tree_with_dependencies(path))
      end

      # Allows you to state a dependency on a file without
      # including it.
      #
      # This is used for caching purposes. Any changes made to
      # the dependency file will invalidate the cache of the
      # source file.
      #
      # This is useful if you are using ERB and File.read to pull
      # in contents from another file.
      #
      #     //= depend_on "foo.png"
      #
      def process_depend_on_directive(path)
        resolve(path)
      end

      # Allows you to state a dependency on an asset without including
      # it.
      #
      # This is used for caching purposes. Any changes that would
      # invalid the asset dependency will invalidate the cache our the
      # source file.
      #
      # Unlike `depend_on`, the path must be a requirable asset.
      #
      #     //= depend_on_asset "bar.js"
      #
      def process_depend_on_asset_directive(path)
        load(resolve(path))
      end

      # Allows dependency to be excluded from the asset bundle.
      #
      # The `path` must be a valid asset and may or may not already
      # be part of the bundle. Once stubbed, it is blacklisted and
      # can't be brought back by any other `require`.
      #
      #     //= stub "jquery"
      #
      def process_stub_directive(path)
        @stubbed << resolve(path, accept: @content_type, pipeline: :self)
      end

      # Declares a linked dependency on the target asset.
      #
      # The `path` must be a valid asset and should not already be part of the
      # bundle. Any linked assets will automatically be compiled along with the
      # current.
      #
      #   /*= link "logo.png" */
      #
      def process_link_directive(path)
        @links << load(resolve(path)).uri
      end

      # `link_directory` links all the files inside a single
      # directory. It's similar to `path/*` since it does not follow
      # nested directories.
      #
      #     //= link_directory "./fonts"
      #
      # Use caution when linking against JS or CSS assets. Include an explicit
      # extension or content type in these cases
      #
      #     //= link_directory "./scripts" .js
      #
      def process_link_directory_directive(path = ".", accept = nil)
        path = expand_relative_dirname(:link_directory, path)
        accept = expand_accept_shorthand(accept)
        link_paths(*@environment.stat_directory_with_dependencies(path), accept)
      end

      # `link_tree` links all the nested files in a directory.
      # Its glob equivalent is `path/**/*`.
      #
      #     //= link_tree "./images"
      #
      # Use caution when linking against JS or CSS assets. Include an explicit
      # extension or content type in these cases
      #
      #     //= link_tree "./styles" .css
      #
      def process_link_tree_directive(path = ".", accept = nil)
        path = expand_relative_dirname(:link_tree, path)
        accept = expand_accept_shorthand(accept)
        link_paths(*@environment.stat_sorted_tree_with_dependencies(path), accept)
      end

    private
      def expand_accept_shorthand(accept)
        if accept.nil?
          nil
        elsif accept.include?("/")
          accept
        elsif accept.start_with?(".")
          @environment.mime_exts[accept]
        else
          @environment.mime_exts[".#{accept}"]
        end
      end

      def require_paths(paths, deps)
        resolve_paths(paths, deps, accept: @content_type, pipeline: :self) do |uri|
          @required << uri
        end
      end

      def link_paths(paths, deps, accept)
        resolve_paths(paths, deps, accept: accept) do |uri|
          @links << load(uri).uri
        end
      end

      def resolve_paths(paths, deps, options = {})
        @dependencies.merge(deps)
        paths.each do |subpath, stat|
          next if subpath == @filename || stat.directory?
          uri, deps = @environment.resolve(subpath, options.merge(compat: false))
          @dependencies.merge(deps)
          yield uri if uri
        end
      end

      def expand_relative_dirname(directive, path)
        if @environment.relative_path?(path)
          path = File.expand_path(path, @dirname)
          stat = @environment.stat(path)

          if stat && stat.directory?
            path
          else
            raise ArgumentError, "#{directive} argument must be a directory"
          end
        else
          # The path must be relative and start with a `./`.
          raise ArgumentError, "#{directive} argument must be a relative path"
        end
      end

      def load(uri)
        asset = @environment.load(uri)
        @dependencies.merge(asset.metadata[:dependencies])
        asset
      end

      def resolve(path, options = {})
        # Prevent absolute paths in directives
        if @environment.absolute_path?(path)
          raise FileOutsidePaths, "can't require absolute file: #{path}"
        end

        uri, deps = @environment.resolve!(path, options.merge(base_path: @dirname))
        @dependencies.merge(deps)
        uri
      end
  end
end
