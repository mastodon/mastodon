module Paperclip
  module Validators
    class AttachmentFileNameValidator < ActiveModel::EachValidator
      def initialize(options)
        options[:allow_nil] = true unless options.has_key?(:allow_nil)
        super
      end

      def self.helper_method_name
        :validates_attachment_file_name
      end

      def validate_each(record, attribute, value)
        base_attribute = attribute.to_sym
        attribute = "#{attribute}_file_name".to_sym
        value = record.send :read_attribute_for_validation, attribute

        return if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])

        validate_whitelist(record, attribute, value)
        validate_blacklist(record, attribute, value)

        if record.errors.include? attribute
          record.errors[attribute].each do |error|
            record.errors.add base_attribute, error
          end
        end
      end

      def validate_whitelist(record, attribute, value)
        if allowed.present? && allowed.none? { |type| type === value }
          mark_invalid record, attribute, allowed
        end
      end

      def validate_blacklist(record, attribute, value)
        if forbidden.present? && forbidden.any? { |type| type === value }
          mark_invalid record, attribute, forbidden
        end
      end

      def mark_invalid(record, attribute, patterns)
        record.errors.add attribute, :invalid, options.merge(:names => patterns.join(', '))
      end

      def allowed
        [options[:matches]].flatten.compact
      end

      def forbidden
        [options[:not]].flatten.compact
      end

      def check_validity!
        unless options.has_key?(:matches) || options.has_key?(:not)
          raise ArgumentError, "You must pass in either :matches or :not to the validator"
        end
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the name of the file
      # assigned. The possible options are:
      # * +matches+: Allowed filename patterns as Regexps. Can be a single one
      #   or an array.
      # * +not+: Forbidden file name patterns, specified the same was as +matches+.
      # * +message+: The message to display when the uploaded file has an invalid
      #   name.
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run is this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def validates_attachment_file_name(*attr_names)
        options = _merge_attributes(attr_names)
        validates_with AttachmentFileNameValidator, options.dup
        validate_before_processing AttachmentFileNameValidator, options.dup
      end
    end
  end
end

