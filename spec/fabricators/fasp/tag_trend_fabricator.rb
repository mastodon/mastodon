# frozen_string_literal: true

Fabricator('Fasp::TagTrend') do
  tag
  fasp_provider
  rank          1
  language      'en'
  allowed       false
end
