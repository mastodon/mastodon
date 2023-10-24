# frozen_string_literal: true

Fabricator(:session_activation) do
  user { Fabricate.build(:user) }
  session_id 'MyString'
end
