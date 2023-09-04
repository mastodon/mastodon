Fabricator(:rule) do
  priority   0
  deleted_at nil
  text       { Faker::Lorem.paragraph }
end
