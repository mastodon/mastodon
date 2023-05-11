# frozen_string_literal: true

Fabricator(:identity) do
  user
  provider 'MyString'
  uid      'MyString'
end
