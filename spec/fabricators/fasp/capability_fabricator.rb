# frozen_string_literal: true

Fabricator(:fasp_capability, from: 'Fasp::Capability') do
  name { sequence(:capability_name) { |i| "capability#{i}" } }
  version '0.1'
  enabled false
  fasp_provider
end
