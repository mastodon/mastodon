require 'active_model/validations/numericality'

module Paperclip
  module Validators
    class AttachmentSizeValidator < ActiveModel::Validations::NumericalityValidator
      AVAILABLE_CHECKS = [:less_than, :less_than_or_equal_to, :greater_than, :greater_than_or_equal_to]

      def initialize(options)
        extract_options(options)
        super
      end

      def self.helper_method_name
        :validates_attachment_size
      end

      def validate_each(record, attr_name, value)
        base_attr_name = attr_name
        attr_name = "#{attr_name}_file_size".to_sym
        value = record.send(:read_attribute_for_validation, attr_name)

        unless value.blank?
          options.slice(*AVAILABLE_CHECKS).each do |option, option_value|
            option_value = option_value.call(record) if option_value.is_a?(Proc)
            option_value = extract_option_value(option, option_value)

            unless value.send(CHECKS[option], option_value)
              error_message_key = options[:in] ? :in_between : option
              [ attr_name, base_attr_name ].each do |error_attr_name|
                record.errors.add(error_attr_name, error_message_key, filtered_options(value).merge(
                  :min => min_value_in_human_size(record),
                  :max => max_value_in_human_size(record),
                  :count => human_size(option_value)
                ))
              end
            end
          end
        end
      end

      def check_validity!
        unless (AVAILABLE_CHECKS + [:in]).any? { |argument| options.has_key?(argument) }
          raise ArgumentError, "You must pass either :less_than, :greater_than, or :in to the validator"
        end
      end

      private

      def extract_options(options)
        if range = options[:in]
          if !options[:in].respond_to?(:call)
            options[:less_than_or_equal_to] = range.max
            options[:greater_than_or_equal_to] = range.min
          else
            options[:less_than_or_equal_to] = range
            options[:greater_than_or_equal_to] = range
          end
        end
      end

      def extract_option_value(option, option_value)
        if option_value.is_a?(Range)
          if [:less_than, :less_than_or_equal_to].include?(option)
            option_value.max
          else
            option_value.min
          end
        else
          option_value
        end
      end

      def human_size(size)
        ActiveSupport::NumberHelper.number_to_human_size(size)
      end

      def min_value_in_human_size(record)
        value = options[:greater_than_or_equal_to] || options[:greater_than]
        value = value.call(record) if value.respond_to?(:call)
        value = value.min if value.respond_to?(:min)
        human_size(value)
      end

      def max_value_in_human_size(record)
        value = options[:less_than_or_equal_to] || options[:less_than]
        value = value.call(record) if value.respond_to?(:call)
        value = value.max if value.respond_to?(:max)
        human_size(value)
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the size of the file assigned. The
      # possible options are:
      # * +in+: a Range of bytes (i.e. +1..1.megabyte+),
      # * +less_than+: equivalent to :in => 0..options[:less_than]
      # * +greater_than+: equivalent to :in => options[:greater_than]..Infinity
      # * +message+: error message to display, use :min and :max as replacements
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run if this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def validates_attachment_size(*attr_names)
        options = _merge_attributes(attr_names)
        validates_with AttachmentSizeValidator, options.dup
        validate_before_processing AttachmentSizeValidator, options.dup
      end
    end
  end
end
