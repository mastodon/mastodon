# frozen_string_literal: true

Fabricator(:account_moderation_note) do
  content 'MyText'
  account nil
end
