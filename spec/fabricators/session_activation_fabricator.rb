# frozen_string_literal: true

Fabricator(:session_activation) do
  user
  session_id 'MyString'
end
