# frozen_string_literal: true

Fabricator(:follow) do
  account
  target_account { Fabricate(:account) }
end
