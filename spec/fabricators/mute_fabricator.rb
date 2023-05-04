# frozen_string_literal: true

Fabricator(:mute) do
  account
  target_account { Fabricate(:account) }
end
