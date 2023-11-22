# frozen_string_literal: true

Fabricator(:custom_filter_account) do
  custom_filter { Fabricate.build(:custom_filter) }
  target_account { Fabricate.build(:account) }
end
