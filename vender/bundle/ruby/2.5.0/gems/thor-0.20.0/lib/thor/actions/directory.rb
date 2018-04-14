require "thor/actions/empty_directory"

class Thor
  module Actions
    # Copies recursively the files from source directory to root directory.
    # If any of the files finishes with .tt, it's considered to be a template
    # and is placed in the destination without the extension .tt. If any
    # empty directory is found, it's copied and all .empty_directory files are
    # ignored. If any file name is wrapped within % signs, the text within
    # the % signs will be executed as a method and replaced with the returned
    # value. Let's suppose a doc directory with the following files:
    #
    #   doc/
    #     components/.empty_directory
    #     README
    #     rdoc.rb.tt
    #     %app_name%.rb
    #
    # When invoked as:
    #
    #   directory "doc"
    #
    # It will create a doc directory in the destination with the following
    # files (assuming that the `app_name` method returns the value "blog"):
    #
    #   doc/
    #     components/
    #     README
    #     rdoc.rb
    #     blog.rb
    #
    # <b>Encoded path note:</b> Since Thor internals use Object#respond_to? to check if it can
    # expand %something%, this `something` should be a public method in the class calling
    # #directory. If a method is private, Thor stack raises PrivateMethodEncodedError.
    #
    # ==== Parameters
    # source<String>:: the relative path to the source root.
    # destination<String>:: the relative path to the destination root.
    # config<Hash>:: give :verbose => false to not log the status.
    #                If :recursive => false, does not look for paths recursively.
    #                If :mode => :preserve, preserve the file mode from the source.
    #                If :exclude_pattern => /regexp/, prevents copying files that match that regexp.
    #
    # ==== Examples
    #
    #   directory "doc"
    #   directory "doc", "docs", :recursive => false
    #
    def directory(source, *args, &block)
      config = args.last.is_a?(Hash) ? args.pop : {}
      destination = args.first || source
      action Directory.new(self, source, destination || source, config, &block)
    end

    class Directory < EmptyDirectory #:nodoc:
      attr_reader :source

      def initialize(base, source, destination = nil, config = {}, &block)
        @source = File.expand_path(base.find_in_source_paths(source.to_s))
        @block  = block
        super(base, destination, {:recursive => true}.merge(config))
      end

      def invoke!
        base.empty_directory given_destination, config
        execute!
      end

      def revoke!
        execute!
      end

    protected

      def execute!
        lookup = Util.escape_globs(source)
        lookup = config[:recursive] ? File.join(lookup, "**") : lookup
        lookup = file_level_lookup(lookup)

        files(lookup).sort.each do |file_source|
          next if File.directory?(file_source)
          next if config[:exclude_pattern] && file_source.match(config[:exclude_pattern])
          file_destination = File.join(given_destination, file_source.gsub(source, "."))
          file_destination.gsub!("/./", "/")

          case file_source
          when /\.empty_directory$/
            dirname = File.dirname(file_destination).gsub(%r{/\.$}, "")
            next if dirname == given_destination
            base.empty_directory(dirname, config)
          when /#{TEMPLATE_EXTNAME}$/
            base.template(file_source, file_destination[0..-4], config, &@block)
          else
            base.copy_file(file_source, file_destination, config, &@block)
          end
        end
      end

      if RUBY_VERSION < "2.0"
        def file_level_lookup(previous_lookup)
          File.join(previous_lookup, "{*,.[a-z]*}")
        end

        def files(lookup)
          Dir[lookup]
        end
      else
        def file_level_lookup(previous_lookup)
          File.join(previous_lookup, "*")
        end

        def files(lookup)
          Dir.glob(lookup, File::FNM_DOTMATCH)
        end
      end
    end
  end
end
