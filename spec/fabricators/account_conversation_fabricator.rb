# frozen_string_literal: true

Fabricator(:account_conversation) do
  account
  conversation
  status_ids { [Fabricate(:status).id] }
end
