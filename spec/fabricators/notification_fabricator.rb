# frozen_string_literal: true

Fabricator(:notification) do
  activity fabricator: [:mention, :status, :follow, :follow_request, :favourite].sample
  account
end
