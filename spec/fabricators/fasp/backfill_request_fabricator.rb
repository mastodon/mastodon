# frozen_string_literal: true

Fabricator(:fasp_backfill_request, from: 'Fasp::BackfillRequest') do
  category      'content'
  max_count     10
  cursor        nil
  fulfilled     false
  fasp_provider
end
