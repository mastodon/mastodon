# frozen_string_literal: true

Fabricator('Emergency::Trigger') do
  emergency_rule { Fabricate('Emergency::Rule') }
  event           'local:signups'
  threshold       1
  duration_bucket 1
end
