module Paperclip
  module Shoulda
    module Matchers
      # Ensures that the given instance or class has an attachment with the
      # given name.
      #
      # Example:
      #   describe User do
      #     it { should have_attached_file(:avatar) }
      #   end
      def have_attached_file name
        HaveAttachedFileMatcher.new(name)
      end

      class HaveAttachedFileMatcher
        def initialize attachment_name
          @attachment_name = attachment_name
        end

        def matches? subject
          @subject = subject
          @subject = @subject.class unless Class === @subject
          responds? && has_column?
        end

        def failure_message
          "Should have an attachment named #{@attachment_name}"
        end

        def failure_message_when_negated
          "Should not have an attachment named #{@attachment_name}"
        end
        alias negative_failure_message failure_message_when_negated

        def description
          "have an attachment named #{@attachment_name}"
        end

        protected

        def responds?
          methods = @subject.instance_methods.map(&:to_s)
          methods.include?("#{@attachment_name}") &&
            methods.include?("#{@attachment_name}=") &&
            methods.include?("#{@attachment_name}?")
        end

        def has_column?
          @subject.column_names.include?("#{@attachment_name}_file_name")
        end
      end
    end
  end
end
