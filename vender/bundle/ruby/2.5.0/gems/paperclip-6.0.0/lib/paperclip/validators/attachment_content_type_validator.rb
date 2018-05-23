module Paperclip
  module Validators
    class AttachmentContentTypeValidator < ActiveModel::EachValidator
      def initialize(options)
        options[:allow_nil] = true unless options.has_key?(:allow_nil)
        super
      end

      def self.helper_method_name
        :validates_attachment_content_type
      end

      def validate_each(record, attribute, value)
        base_attribute = attribute.to_sym
        attribute = "#{attribute}_content_type".to_sym
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
        if allowed_types.present? && allowed_types.none? { |type| type === value }
          mark_invalid record, attribute, allowed_types
        end
      end

      def validate_blacklist(record, attribute, value)
        if forbidden_types.present? && forbidden_types.any? { |type| type === value }
          mark_invalid record, attribute, forbidden_types
        end
      end

      def mark_invalid(record, attribute, types)
        record.errors.add attribute, :invalid, options.merge(:types => types.join(', '))
      end

      def allowed_types
        [options[:content_type]].flatten.compact
      end

      def forbidden_types
        [options[:not]].flatten.compact
      end

      def check_validity!
        unless options.has_key?(:content_type) || options.has_key?(:not)
          raise ArgumentError, "You must pass in either :content_type or :not to the validator"
        end
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the content type of the file
      # assigned. The possible options are:
      # * +content_type+: Allowed content types.  Can be a single content type
      #   or an array.  Each type can be a String or a Regexp. It should be
      #   noted that Internet Explorer uploads files with content_types that you
      #   may not expect. For example, JPEG images are given image/pjpeg and
      #   PNGs are image/x-png, so keep that in mind when determining how you
      #   match.  Allows all by default.
      # * +not+: Forbidden content types.
      # * +message+: The message to display when the uploaded file has an invalid
      #   content type.
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run is this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      # NOTE: If you do not specify an [attachment]_content_type field on your
      # model, content_type validation will work _ONLY upon assignment_ and
      # re-validation after the instance has been reloaded will always succeed.
      # You'll still need to have a virtual attribute (created by +attr_accessor+)
      # name +[attachment]_content_type+ to be able to use this validator.
      def validates_attachment_content_type(*attr_names)
        options = _merge_attributes(attr_names)
        validates_with AttachmentContentTypeValidator, options.dup
        validate_before_processing AttachmentContentTypeValidator, options.dup
      end
    end
  end
end
