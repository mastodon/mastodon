require 'active_model/validations/presence'

module Paperclip
  module Validators
    class AttachmentFileTypeIgnoranceValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        # This doesn't do anything. It's just to mark that you don't care about
        # the file_names or content_types of your incoming attachments.
      end

      def self.helper_method_name
        :do_not_validate_attachment_file_type
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the presence of a file.
      # Options:
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run if this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def do_not_validate_attachment_file_type(*attr_names)
        options = _merge_attributes(attr_names)
        validates_with AttachmentFileTypeIgnoranceValidator, options.dup
      end
    end
  end
end

