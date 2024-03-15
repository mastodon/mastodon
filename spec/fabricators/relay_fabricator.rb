# frozen_string_literal: true

Fabricator(:relay) do
  inbox_url { sequence(:inbox_url) { |i| "https://example.com/inboxes/#{i}" } }
  state :idle
end
