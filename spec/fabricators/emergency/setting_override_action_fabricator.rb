# frozen_string_literal: true

Fabricator('Emergency::SettingOverrideAction') do
  emergency_rule { Fabricate('Emergency::Rule') }
  setting        'registrations_mode'
  value          'closed'
end
