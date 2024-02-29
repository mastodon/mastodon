# frozen_string_literal: true

Fabricator(:software_update) do
  version { sequence(:version) { |point| "99.99.#{point}" } }
  urgent false
  type 'patch'
end
