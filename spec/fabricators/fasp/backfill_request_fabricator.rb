# frozen_string_literal: true

Fabricator('Fasp::BackfillRequest') do
  category      'MyString'
  max_count     1
  cursor        'MyString'
  fulfilled     false
  fasp_provider nil
end
