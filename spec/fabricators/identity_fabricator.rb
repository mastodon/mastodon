# frozen_string_literal: true

Fabricator(:identity) do
  user { Fabricate.build(:user) }
  provider 'MyString'
  uid { sequence(:uid) { |i| "uid_string_#{i}" } }
end
