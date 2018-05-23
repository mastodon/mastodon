require 'pathname'

module Aws
  module S3
    # @api private
    class FileUploader

      FIFTEEN_MEGABYTES = 15 * 1024 * 1024

      # @option options [Client] :client
      # @option options [Integer] :multipart_threshold Files greater than
      #   `:multipart_threshold` bytes are uploaded using S3 multipart APIs.
      def initialize(options = {})
        @options = options
        @client = options[:client] || Client.new
        @multipart_threshold = options[:multipart_threshold] || FIFTEEN_MEGABYTES
      end

      # @return [Client]
      attr_reader :client

      # @return [Integer] Files larger than this in bytes are uploaded
      #   using a {MultipartFileUploader}.
      attr_reader :multipart_threshold

      # @param [String,Pathname,File,Tempfile] source
      # @option options [required,String] :bucket
      # @option options [required,String] :key
      # @return [void]
      def upload(source, options = {})
        if File.size(source) >= multipart_threshold
          MultipartFileUploader.new(@options).upload(source, options)
        else
          put_object(source, options)
        end
      end

      private

      def put_object(source, options)
        open_file(source) do |file|
          @client.put_object(options.merge(body: file))
        end
      end

      def open_file(source)
        if String === source || Pathname === source
          file = File.open(source, 'rb')
          yield(file)
          file.close
        else
          yield(source)
        end
      end

    end
  end
end
