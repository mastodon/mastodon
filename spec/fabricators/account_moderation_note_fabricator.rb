# frozen_string_literal: true

Fabricator(:account_moderation_note) do
  content 'MyText'
  account { Fabricate.build(:account) }
  target_account { Fabricate.build(:account) }
end
