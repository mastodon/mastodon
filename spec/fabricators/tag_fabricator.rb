# frozen_string_literal: true

Fabricator(:tag) do
  name { sequence(:hashtag) { |i| "tag#{i}" } }
end
