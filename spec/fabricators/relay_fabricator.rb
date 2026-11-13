# frozen_string_literal: true

Fabricator(:relay) do
  account { |_attrs| Fabricate(:account, protocol: :activitypub, domain: 'example.com', uri: sequence(:uri) { |i| "https://example.com/#{i}" }, inbox_url: sequence(:inbox_url) { |i| "https://example.com/inboxes/#{i}" }) }
  uri { |attrs| attrs[:account].uri }
  inbox_url { |attrs| attrs[:account].inbox_url }
  direction :bidirectional
  requires_opt_in false
  state :idle
end
