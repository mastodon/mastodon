Fabricator(:boosts_mute) do
  account
  target_account { Fabricate(:account) }
end
