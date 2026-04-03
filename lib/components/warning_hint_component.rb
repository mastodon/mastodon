# frozen_string_literal: true

module WarningHintComponent
  def warning_hint(_wrapper_options = nil)
    @warning_hint ||= begin
      options[:warning_hint].to_s.html_safe if options[:warning_hint].present? # rubocop:disable Rails/OutputSafety
    end
  end
end

SimpleForm.include_component(WarningHintComponent)
