# frozen_string_literal: true

Fabricator(:status_stat) do
  status
  replies_count '123'
  reblogs_count '456'
  favourites_count '789'
end
