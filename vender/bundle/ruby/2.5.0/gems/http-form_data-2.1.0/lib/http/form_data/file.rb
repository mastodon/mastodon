# frozen_string_literal: true

module HTTP
  module FormData
    # Represents file form param.
    #
    # @example Usage with StringIO
    #
    #  io = StringIO.new "foo bar baz"
    #  FormData::File.new io, :filename => "foobar.txt"
    #
    # @example Usage with IO
    #
    #  File.open "/home/ixti/avatar.png" do |io|
    #    FormData::File.new io
    #  end
    #
    # @example Usage with pathname
    #
    #  FormData::File.new "/home/ixti/avatar.png"
    class File < Part
      # Default MIME type
      DEFAULT_MIME = "application/octet-stream"

      # @deprecated Use #content_type instead
      alias mime_type content_type

      # @see DEFAULT_MIME
      # @param [String, Pathname, IO] path_or_io Filename or IO instance.
      # @param [#to_h] opts
      # @option opts [#to_s] :content_type (DEFAULT_MIME)
      #   Value of Content-Type header
      # @option opts [#to_s] :filename
      #   When `path_or_io` is a String, Pathname or File, defaults to basename.
      #   When `path_or_io` is a IO, defaults to `"stream-{object_id}"`.
      def initialize(path_or_io, opts = {})
        opts = FormData.ensure_hash(opts)

        if opts.key? :mime_type
          warn "[DEPRECATED] :mime_type option deprecated, use :content_type"
          opts[:content_type] = opts[:mime_type]
        end

        @io           = make_io(path_or_io)
        @content_type = opts.fetch(:content_type, DEFAULT_MIME).to_s
        @filename     = opts.fetch(:filename, filename_for(@io))
      end

      private

      def make_io(path_or_io)
        if path_or_io.is_a?(String)
          ::File.open(path_or_io, :binmode => true)
        elsif defined?(Pathname) && path_or_io.is_a?(Pathname)
          path_or_io.open(:binmode => true)
        else
          path_or_io
        end
      end

      def filename_for(io)
        if io.respond_to?(:path)
          ::File.basename io.path
        else
          "stream-#{io.object_id}"
        end
      end
    end
  end
end
