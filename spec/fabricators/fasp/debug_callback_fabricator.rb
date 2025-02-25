# frozen_string_literal: true

Fabricator(:fasp_debug_callback, from: 'Fasp::DebugCallback') do
  fasp_provider
  ip            '127.0.0.234'
  request_body  'MyText'
end
