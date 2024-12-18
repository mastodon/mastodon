# frozen_string_literal: true

Fabricator(:custom_emoji_category) do
  name { sequence(:name) { |i| "name_#{i}" } }
end
