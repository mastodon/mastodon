# frozen_string_literal: true

Fabricator(:relay_preference) do
  account
  relay
  enabled true
end
