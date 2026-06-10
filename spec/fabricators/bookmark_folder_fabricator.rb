# frozen_string_literal: true

Fabricator(:bookmark_folder) do
  account { Fabricate.build(:account) }
  title 'MyString'
end
