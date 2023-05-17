# frozen_string_literal: true

Fabricator('Emergency::Rule') do
  name         'server lockdown'
  duration     5.minutes.to_i
end
