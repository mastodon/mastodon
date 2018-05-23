module Paperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the size of the
      # given attachment as specified.
      #
      # Examples:
      #   it { should validate_attachment_size(:avatar).
      #                 less_than(2.megabytes) }
      #   it { should validate_attachment_size(:icon).
      #                 greater_than(1024) }
      #   it { should validate_attachment_size(:icon).
      #                 in(0..100) }
      def validate_attachment_size name
        ValidateAttachmentSizeMatcher.new(name)
      end

      class ValidateAttachmentSizeMatcher
        def initialize attachment_name
          @attachment_name = attachment_name
        end

        def less_than size
          @high = size
          self
        end

        def greater_than size
          @low = size
          self
        end

        def in range
          @low, @high = range.first, range.last
          self
        end

        def matches? subject
          @subject = subject
          @subject = @subject.new if @subject.class == Class
          lower_than_low? && higher_than_low? && lower_than_high? && higher_than_high?
        end

        def failure_message
          "Attachment #{@attachment_name} must be between #{@low} and #{@high} bytes"
        end

        def failure_message_when_negated
          "Attachment #{@attachment_name} cannot be between #{@low} and #{@high} bytes"
        end
        alias negative_failure_message failure_message_when_negated

        def description
          "validate the size of attachment #{@attachment_name}"
        end

        protected

        def override_method object, method, &replacement
          (class << object; self; end).class_eval do
            define_method(method, &replacement)
          end
        end

        def passes_validation_with_size(new_size)
          file = StringIO.new(".")
          override_method(file, :size){ new_size }
          override_method(file, :to_tempfile){ file }

          @subject.send(@attachment_name).post_processing = false
          @subject.send(@attachment_name).assign(file)
          @subject.valid?
          @subject.errors[:"#{@attachment_name}_file_size"].blank?
        ensure
          @subject.send(@attachment_name).post_processing = true
        end

        def lower_than_low?
          @low.nil? || !passes_validation_with_size(@low - 1)
        end

        def higher_than_low?
          @low.nil? || passes_validation_with_size(@low + 1)
        end

        def lower_than_high?
          @high.nil? || @high == Float::INFINITY || passes_validation_with_size(@high - 1)
        end

        def higher_than_high?
          @high.nil? || @high == Float::INFINITY || !passes_validation_with_size(@high + 1)
        end
      end
    end
  end
end
