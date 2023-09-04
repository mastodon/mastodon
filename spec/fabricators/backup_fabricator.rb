# frozen_string_literal: true

Fabricator(:backup) do
  user { Fabricate.build(:user) }
end
