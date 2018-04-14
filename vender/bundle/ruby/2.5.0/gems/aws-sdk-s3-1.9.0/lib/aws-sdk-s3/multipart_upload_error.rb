module Aws
  module S3
    class MultipartUploadError < StandardError

      def initialize(message, errors)
        @errors = errors
        super(message)
      end

      # @return [Array<StandardError>] The list of errors encountered
      #   when uploading or aborting the upload.
      attr_reader :errors

    end
  end
end
