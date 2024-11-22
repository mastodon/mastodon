# frozen_string_literal: true

Fabricator(:list) do
  account { Fabricate.build(:account) }
  title 'MyString'
end
