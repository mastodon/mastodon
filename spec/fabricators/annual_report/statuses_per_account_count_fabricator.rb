# frozen_string_literal: true

Fabricator :annual_report_statuses_per_account_count, from: 'AnnualReport::StatusesPerAccountCount' do
  year { Time.zone.now.year }
  account_id { Fabricate(:account).id }
  statuses_count { 123 }
end
