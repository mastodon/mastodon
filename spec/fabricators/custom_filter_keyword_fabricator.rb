# frozen_string_literal: true

Fabricator(:custom_filter_keyword) do
  custom_filter { Fabricate.build(:custom_filter) }
  keyword 'discourse'
end
