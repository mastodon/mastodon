# frozen_string_literal: true

Fabricator(:custom_filter) do
  account
  expires_at nil
  phrase     'discourse'
  context    %w(home notifications)
end
