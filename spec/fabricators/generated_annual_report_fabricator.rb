# frozen_string_literal: true

Fabricator(:generated_annual_report) do
  account { Fabricate.build(:account) }
  data { { test: :data } }
  schema_version { AnnualReport::SCHEMA }
  year { sequence(:year) { |i| 2000 + i } }
end
