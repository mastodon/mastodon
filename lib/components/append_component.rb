# frozen_string_literal: true

module AppendComponent
  def append(_wrapper_options = nil)
    @append ||= begin
      options[:append].to_s.html_safe if options[:append].present? # rubocop:disable Rails/OutputSafety
    end
  end
end

SimpleForm.include_component(AppendComponent)
