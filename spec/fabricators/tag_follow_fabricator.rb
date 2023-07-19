# frozen_string_literal: true

Fabricator(:tag_follow) do
  tag
  account { Fabricate.build(:account) }
end
