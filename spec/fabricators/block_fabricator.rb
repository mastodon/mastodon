Fabricator(:block) do
  account
  target_account { Fabricate(:account) }
end
