# frozen_string_literal: true

Fabricator('Fasp::StatusTrend') do
  status
  fasp_provider
  rank          1
  language      'en'
  allowed       false
end
