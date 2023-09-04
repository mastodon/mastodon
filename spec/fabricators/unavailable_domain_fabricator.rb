Fabricator(:unavailable_domain) do
  domain { Faker::Internet.domain }
end
