# frozen_string_literal: true

Fabricator(:marker) do
  user { Fabricate.build(:user) }
  timeline     'home'
  last_read_id 0
  lock_version 0
end
