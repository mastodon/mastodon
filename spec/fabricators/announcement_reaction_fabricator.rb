# frozen_string_literal: true

Fabricator(:announcement_reaction) do
  account { Fabricate.build(:account) }
  announcement { Fabricate.build(:announcement) }
  name { Fabricate(:custom_emoji).shortcode }
end
