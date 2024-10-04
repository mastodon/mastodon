# frozen_string_literal: true

Fabricator(:account_moderation_note) do
  content { Faker::Lorem.sentences }
  account { Fabricate.build(:account) }
  target_account { Fabricate.build(:account) }
end
