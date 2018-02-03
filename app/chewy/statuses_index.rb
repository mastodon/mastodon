# frozen_string_literal: true

class StatusesIndex < Chewy::Index
  define_type Status do
    root date_detection: false do
      field :text, type: 'text', value: ->(status) { [status.spoiler_text, Formatter.instance.plaintext(status)].join("\n\n") }
      field :searchable_by, type: 'long'
    end
  end
end
