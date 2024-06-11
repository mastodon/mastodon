# frozen_string_literal: true

Fabricator(:announcement) do
  text      { Faker::Lorem.paragraph(sentence_count: 2) }
  published true
  starts_at nil
  ends_at   nil
end
