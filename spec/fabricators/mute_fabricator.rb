Fabricator(:mute) do
  account
  target_account { Fabricate(:account) }
end
