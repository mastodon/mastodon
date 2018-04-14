require 'active_model/validations/presence'

module Paperclip
  module Validators
    class AttachmentPresenceValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if record.send("#{attribute}_file_name").blank?
          record.errors.add(attribute, :blank, options)
        end
      end

      def self.helper_method_name
        :validates_attachment_presence
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the presence of a file.
      # Options:
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run if this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def validates_attachment_presence(*attr_names)
        options = _merge_attributes(attr_names)
        validates_with AttachmentPresenceValidator, options.dup
        validate_before_processing AttachmentPresenceValidator, options.dup
      end
    end
  end
end
