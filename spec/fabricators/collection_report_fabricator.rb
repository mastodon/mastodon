# frozen_string_literal: true

Fabricator(:collection_report) do
  report { Fabricate.build(:report) }
  collection { Fabricate.build(:collection) }
end
