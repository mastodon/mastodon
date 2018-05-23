module Aws
  module S3
    class ObjectSummary

      alias content_length size

      # @param (see Object#copy_from)
      # @options (see Object#copy_from)
      # @return (see Object#copy_from)
      # @see Object#copy_from
      def copy_from(source, options = {})
        object.copy_from(source, options)
      end

      # @param (see Object#copy_to)
      # @options (see Object#copy_to)
      # @return (see Object#copy_to)
      # @see Object#copy_to
      def copy_to(target, options = {})
        object.copy_to(target, options)
      end

      # @param (see Object#move_to)
      # @options (see Object#move_to)
      # @return (see Object#move_to)
      # @see Object#move_to
      def move_to(target, options = {})
        object.move_to(target, options)
      end

      # @param (see Object#presigned_post)
      # @options (see Object#presigned_post)
      # @return (see Object#presigned_post)
      # @see Object#presigned_post
      def presigned_post(options = {})
        object.presigned_post(options)
      end

      # @param (see Object#presigned_url)
      # @options (see Object#presigned_url)
      # @return (see Object#presigned_url)
      # @see Object#presigned_url
      def presigned_url(http_method, params = {})
        object.presigned_url(http_method, params)
      end

      # @param (see Object#public_url)
      # @options (see Object#public_url)
      # @return (see Object#public_url)
      # @see Object#public_url
      def public_url(options = {})
        object.public_url(options)
      end

      # @param (see Object#upload_file)
      # @options (see Object#upload_file)
      # @return (see Object#upload_file)
      # @see Object#upload_file
      def upload_file(source, options = {})
        object.upload_file(source, options)
      end

      # @param (see Object#download_file)
      # @options (see Object#download_file)
      # @return (see Object#download_file)
      # @see Object#download_file
      def download_file(destination, options = {})
        object.download_file(destination, options)
      end

    end
  end
end
