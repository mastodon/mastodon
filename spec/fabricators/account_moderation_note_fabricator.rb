# frozen_string_literal: true

Fabricator(:account_moderation_note) do
  content { 'Account moderation note content' }
  account { Fabricate.build(:account) }
  target_account { Fabricate.build(:account) }
end
