# frozen_string_literal: true

Fabricator(:featured_tag) do
  account
  tag
  name 'Tag'
end
