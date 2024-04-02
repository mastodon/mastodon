# frozen_string_literal: true

Fabricator(:announcement_mute) do
  announcement { Fabricate.build(:announcement) }
  account { Fabricate.build(:account) }
end
