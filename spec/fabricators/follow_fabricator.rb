Fabricator(:follow) do
  account
  target_account { Fabricate(:account) }
end
