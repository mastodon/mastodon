# frozen_string_literal: true

Fabricator(:software_update) do
  version '99.99.99'
  urgent false
  type 'patch'
end
