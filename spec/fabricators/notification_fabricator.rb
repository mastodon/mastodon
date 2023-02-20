# frozen_string_literal: true

Fabricator(:notification) do
  activity fabricator: %i(mention status follow follow_request favourite).sample
  account
end
