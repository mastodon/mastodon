# frozen_string_literal: true
module SimpleForm
  module Components
    # Needs to be enabled in order to do automatic lookups.
    module Hints
      def hint(wrapper_options = nil)
        @hint ||= begin
          hint = options[:hint]

          if hint.is_a?(String)
            html_escape(hint)
          else
            content = translate_from_namespace(:hints)
            content.html_safe if content
          end
        end
      end

      def has_hint?
        options[:hint] != false && hint.present?
      end
    end
  end
end
