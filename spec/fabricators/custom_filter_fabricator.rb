Fabricator(:custom_filter) do
  account
  expired_at nil
  phrase     'discourse'
  context    %w(home notifications)
end
