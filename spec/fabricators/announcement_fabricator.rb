# frozen_string_literal: true

Fabricator(:announcement) do
  text      { 'An announcement has been made. This is that very announcement.' }
  published true
  starts_at nil
  ends_at   nil
end
