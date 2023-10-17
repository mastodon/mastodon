# frozen_string_literal: true

Fabricator(:relay) do
  inbox_url 'https://example.com/inbox'
  state :idle
end
