# frozen_string_literal: true

Fabricator(:status_edit) do
  status                    nil
  account                   nil
  text                      'MyText'
  spoiler_text              'MyText'
  media_attachments_changed false
end
