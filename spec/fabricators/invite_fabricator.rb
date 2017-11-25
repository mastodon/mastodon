Fabricator(:invite) do
  user       nil
  code       "MyString"
  expires_at "2017-11-25 03:49:30"
  max_uses   1
  uses       1
end
