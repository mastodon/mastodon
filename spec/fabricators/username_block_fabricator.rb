# frozen_string_literal: true

Fabricator(:username_block) do
  username 'foo'
  exact false
  allow_with_approval false
end
