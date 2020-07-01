# frozen_string_literal: true

require 'mime/types/columnar'

module Paperclip
  class ImageExtractor < Paperclip::Processor
    def make
      return @file unless options[:style] == :original

      image = extract_image_from_file!

      unless image.nil?
        begin
          attachment.instance.thumbnail = image if image.size.positive?
        ensure
          # Paperclip does not automatically delete the source file of
          # a new attachment while working on copies of it, so we need
          # to make sure it's cleaned up

          begin
            image.close(true)
          rescue Errno::ENOENT
            nil
          end
        end
      end

      @file
    end

    private

    def extract_image_from_file!
      ::Av.logger = Paperclip.logger

      cli = ::Av.cli
      dst = Tempfile.new([File.basename(@file.path, '.*'), '.png'])
      dst.binmode

      cli.add_source(@file.path)
      cli.add_destination(dst.path)
      cli.add_output_param loglevel: 'fatal'

      begin
        cli.run
      rescue Cocaine::ExitStatusError
        dst.close(true)
        return nil
      end

      dst
    end
  end
end
