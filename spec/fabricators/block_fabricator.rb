# frozen_string_literal: true

Fabricator(:block) do
  account
  target_account { Fabricate(:account) }
end
