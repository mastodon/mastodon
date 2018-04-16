module Paperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the presence of the
      # given attachment.
      #
      # describe User do
      #   it { should validate_attachment_presence(:avatar) }
      # end
      def validate_attachment_presence name
        ValidateAttachmentPresenceMatcher.new(name)
      end

      class ValidateAttachmentPresenceMatcher
        def initialize attachment_name
          @attachment_name = attachment_name
        end

        def matches? subject
          @subject = subject
          @subject = subject.new if subject.class == Class
          error_when_not_valid? && no_error_when_valid?
        end

        def failure_message
          "Attachment #{@attachment_name} should be required"
        end

        def failure_message_when_negated
          "Attachment #{@attachment_name} should not be required"
        end
        alias negative_failure_message failure_message_when_negated

        def description
          "require presence of attachment #{@attachment_name}"
        end

        protected

        def error_when_not_valid?
          @subject.send(@attachment_name).assign(nil)
          @subject.valid?
          @subject.errors[:"#{@attachment_name}"].present?
        end

        def no_error_when_valid?
          @file = StringIO.new(".")
          @subject.send(@attachment_name).assign(@file)
          @subject.valid?
          expected_message = [
            @attachment_name.to_s.titleize,
            I18n.t(:blank, scope: [:errors, :messages])
          ].join(' ')
          @subject.errors.full_messages.exclude?(expected_message)
        end
      end
    end
  end
end
