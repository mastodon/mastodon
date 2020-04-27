# frozen_string_literal: true

require 'mime/types/columnar'

module Paperclip
  class TypeCorrector < Paperclip::Processor
    def make
      target_extension = options[:format]
      extension        = File.extname(attachment.instance.file_file_name)

      return @file unless options[:style] == :original && target_extension && extension != target_extension

      attachment.instance.file_content_type = options[:content_type] || attachment.instance.file_content_type
      attachment.instance.file_file_name    = File.basename(attachment.instance.file_file_name, '.*') + '.' + target_extension

      @file
    end
  end
end
