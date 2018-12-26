Fabricator(:invite) do
  user
  expires_at nil
  max_uses   nil
  uses       0
end
