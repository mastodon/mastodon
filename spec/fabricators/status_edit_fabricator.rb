# frozen_string_literal: true

Fabricator(:status_edit) do
  status { Fabricate.build(:status) }
end
