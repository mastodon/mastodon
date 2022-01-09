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
      dst = Tempfile.new([File.basename(@file.path, '.*'), '.png'])
      dst.binmode

      begin
        command = Terrapin::CommandLine.new('ffmpeg', '-i :source -loglevel :loglevel -y :destination', logger: Paperclip.logger)
        command.run(source: @file.path, destination: dst.path, loglevel: 'fatal')
      rescue Terrapin::ExitStatusError
        dst.close(true)
        return nil
      rescue Terrapin::CommandNotFoundError
        raise Paperclip::Errors::CommandNotFoundError, 'Could not run the `ffmpeg` command. Please install ffmpeg.'
      end

      dst
    end
  end
end
