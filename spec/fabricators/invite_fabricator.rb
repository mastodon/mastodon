# frozen_string_literal: true

Fabricator(:invite) do
  user { Fabricate.build(:user) }
  expires_at nil
  max_uses   nil
  uses       0
end
