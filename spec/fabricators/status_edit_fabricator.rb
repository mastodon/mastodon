# frozen_string_literal: true

Fabricator(:status_edit) do
  status { Fabricate.build(:status) }
  created_at { DateTime.new(2024, 11, 28, 16, 20, 0) }
end
