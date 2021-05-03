# frozen_string_literal: true

require 'mime/types/columnar'

module Paperclip
  class TypeCorrector < Paperclip::Processor
    def make
      return @file unless options[:format]

      target_extension = '.' + options[:format]
      extension        = File.extname(attachment.instance_read(:file_name))

      return @file unless options[:style] == :original && target_extension && extension != target_extension

      attachment.instance_write(:content_type, options[:content_type] || attachment.instance_read(:content_type))
      attachment.instance_write(:file_name, File.basename(attachment.instance_read(:file_name), '.*') + target_extension)

      @file
    end
  end
end
