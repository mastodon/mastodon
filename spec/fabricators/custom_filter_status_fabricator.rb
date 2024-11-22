# frozen_string_literal: true

Fabricator(:custom_filter_status) do
  custom_filter { Fabricate.build(:custom_filter) }
  status { Fabricate.build(:status) }
end
