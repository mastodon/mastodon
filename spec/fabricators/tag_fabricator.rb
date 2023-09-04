# frozen_string_literal: true

Fabricator(:tag) do
  name { sequence(:hashtag) { |i| "#{Faker::Lorem.word}#{i}" } }
end
