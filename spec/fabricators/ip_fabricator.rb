# frozen_string_literal: true

Fabricator(:ip) do
  ip { '10.0.0.1' }
  used_at { DateTime.new(2024, 11, 28, 16, 20, 0) }
end
