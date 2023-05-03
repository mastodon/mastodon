# frozen_string_literal: true

Fabricator(:account_moderation_note) do
  content 'MyText'
  account
  target_account { Fabricate(:account) }
end
