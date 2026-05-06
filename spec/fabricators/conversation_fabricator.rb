# frozen_string_literal: true

Fabricator(:conversation) do
  parent_account { Fabricate(:account) }
end
