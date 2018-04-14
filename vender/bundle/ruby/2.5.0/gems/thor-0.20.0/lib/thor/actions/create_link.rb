require "thor/actions/create_file"

class Thor
  module Actions
    # Create a new file relative to the destination root from the given source.
    #
    # ==== Parameters
    # destination<String>:: the relative path to the destination root.
    # source<String|NilClass>:: the relative path to the source root.
    # config<Hash>:: give :verbose => false to not log the status.
    #   :: give :symbolic => false for hard link.
    #
    # ==== Examples
    #
    #   create_link "config/apache.conf", "/etc/apache.conf"
    #
    def create_link(destination, *args)
      config = args.last.is_a?(Hash) ? args.pop : {}
      source = args.first
      action CreateLink.new(self, destination, source, config)
    end
    alias_method :add_link, :create_link

    # CreateLink is a subset of CreateFile, which instead of taking a block of
    # data, just takes a source string from the user.
    #
    class CreateLink < CreateFile #:nodoc:
      attr_reader :data

      # Checks if the content of the file at the destination is identical to the rendered result.
      #
      # ==== Returns
      # Boolean:: true if it is identical, false otherwise.
      #
      def identical?
        exists? && File.identical?(render, destination)
      end

      def invoke!
        invoke_with_conflict_check do
          require "fileutils"
          FileUtils.mkdir_p(File.dirname(destination))
          # Create a symlink by default
          config[:symbolic] = true if config[:symbolic].nil?
          File.unlink(destination) if exists?
          if config[:symbolic]
            File.symlink(render, destination)
          else
            File.link(render, destination)
          end
        end
        given_destination
      end

      def exists?
        super || File.symlink?(destination)
      end
    end
  end
end
