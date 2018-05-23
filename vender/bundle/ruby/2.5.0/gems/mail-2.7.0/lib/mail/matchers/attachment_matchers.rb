# frozen_string_literal: true
module Mail
  module Matchers
    def any_attachment
      AnyAttachmentMatcher.new
    end

    def an_attachment_with_filename(filename)
      AttachmentFilenameMatcher.new(filename)
    end

    class AnyAttachmentMatcher
      def ===(other)
        other.attachment?
      end
    end

    class AttachmentFilenameMatcher
      attr_reader :filename
      def initialize(filename)
        @filename = filename
      end

      def ===(other)
        other.attachment? && other.filename == filename
      end
    end
  end
end
