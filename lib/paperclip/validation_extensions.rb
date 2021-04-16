# frozen_string_literal: true

# Monkey-patch various Paperclip validators for Ruby 3.0 compatibility

module Paperclip
  module Validators
    module AttachmentSizeValidatorExtensions
      def validate_each(record, attr_name, _value)
        base_attr_name = attr_name
        attr_name = "#{attr_name}_file_size".to_sym
        value = record.send(:read_attribute_for_validation, attr_name)

        if value.present?
          options.slice(*Paperclip::Validators::AttachmentSizeValidator::AVAILABLE_CHECKS).each do |option, option_value|
            option_value = option_value.call(record) if option_value.is_a?(Proc)
            option_value = extract_option_value(option, option_value)

            next if value.send(Paperclip::Validators::AttachmentSizeValidator::CHECKS[option], option_value)

            error_message_key = options[:in] ? :in_between : option
            [attr_name, base_attr_name].each do |error_attr_name|
              record.errors.add(error_attr_name, error_message_key, **filtered_options(value).merge(
                min: min_value_in_human_size(record),
                max: max_value_in_human_size(record),
                count: human_size(option_value)
              ))
            end
          end
        end
      end
    end

    module AttachmentContentTypeValidatorExtensions
      def mark_invalid(record, attribute, types)
        record.errors.add attribute, :invalid, **options.merge({ types: types.join(', ') })
      end
    end

    module AttachmentPresenceValidatorExtensions
      def validate_each(record, attribute, _value)
        if record.send("#{attribute}_file_name").blank?
          record.errors.add(attribute, :blank, **options)
        end
      end
    end

    module AttachmentFileNameValidatorExtensions
      def mark_invalid(record, attribute, patterns)
        record.errors.add attribute, :invalid, options.merge({ names: patterns.join(', ') })
      end
    end
  end
end

Paperclip::Validators::AttachmentSizeValidator.prepend(Paperclip::Validators::AttachmentSizeValidatorExtensions)
Paperclip::Validators::AttachmentContentTypeValidator.prepend(Paperclip::Validators::AttachmentContentTypeValidatorExtensions)
Paperclip::Validators::AttachmentPresenceValidator.prepend(Paperclip::Validators::AttachmentPresenceValidatorExtensions)
Paperclip::Validators::AttachmentFileNameValidator.prepend(Paperclip::Validators::AttachmentFileNameValidatorExtensions)
