module Paperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class validates the content type of
      # the given attachment as specified.
      #
      # Example:
      #   describe User do
      #     it { should validate_attachment_content_type(:icon).
      #                   allowing('image/png', 'image/gif').
      #                   rejecting('text/plain', 'text/xml') }
      #   end
      def validate_attachment_content_type name
        ValidateAttachmentContentTypeMatcher.new(name)
      end

      class ValidateAttachmentContentTypeMatcher
        def initialize attachment_name
          @attachment_name = attachment_name
          @allowed_types = []
          @rejected_types = []
        end

        def allowing *types
          @allowed_types = types.flatten
          self
        end

        def rejecting *types
          @rejected_types = types.flatten
          self
        end

        def matches? subject
          @subject = subject
          @subject = @subject.new if @subject.class == Class
          @allowed_types && @rejected_types &&
          allowed_types_allowed? && rejected_types_rejected?
        end

        def failure_message
          "#{expected_attachment}\n".tap do |message|
            message << accepted_types_and_failures.to_s
            message << "\n\n" if @allowed_types.present? && @rejected_types.present?
            message << rejected_types_and_failures.to_s
          end
        end

        def description
          "validate the content types allowed on attachment #{@attachment_name}"
        end

        protected

        def accepted_types_and_failures
          if @allowed_types.present?
            "Accept content types: #{@allowed_types.join(", ")}\n".tap do |message|
              if @missing_allowed_types.present?
                message << "  #{@missing_allowed_types.join(", ")} were rejected."
              else
                message << "  All were accepted successfully."
              end
            end
          end
        end
        def rejected_types_and_failures
          if @rejected_types.present?
            "Reject content types: #{@rejected_types.join(", ")}\n".tap do |message|
              if @missing_rejected_types.present?
                message << "  #{@missing_rejected_types.join(", ")} were accepted."
              else
                message << "  All were rejected successfully."
              end
            end
          end
        end

        def expected_attachment
          "Expected #{@attachment_name}:\n"
        end

        def type_allowed?(type)
          @subject.send("#{@attachment_name}_content_type=", type)
          @subject.valid?
          @subject.errors[:"#{@attachment_name}_content_type"].blank?
        end

        def allowed_types_allowed?
          @missing_allowed_types ||= @allowed_types.reject { |type| type_allowed?(type) }
          @missing_allowed_types.none?
        end

        def rejected_types_rejected?
          @missing_rejected_types ||= @rejected_types.select { |type| type_allowed?(type) }
          @missing_rejected_types.none?
        end
      end
    end
  end
end
