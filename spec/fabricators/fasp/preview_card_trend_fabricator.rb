# frozen_string_literal: true

Fabricator('Fasp::PreviewCardTrend') do
  preview_card
  fasp_provider
  rank          1
  language      'en'
  allowed       false
end
