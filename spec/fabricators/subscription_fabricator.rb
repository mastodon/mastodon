Fabricator(:subscription) do
  account
  callback_url "http://example.com/callback"
  secret       "foobar"
  expires_at   "2016-11-28 11:30:07"
  confirmed    false
end
