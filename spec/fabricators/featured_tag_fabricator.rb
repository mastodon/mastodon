# frozen_string_literal: true

Fabricator(:featured_tag) do
  account { Fabricate.build(:account) }
  tag { Fabricate.build(:tag) }
  name { sequence(:name) { |i| "Tag#{i}" } }
end
