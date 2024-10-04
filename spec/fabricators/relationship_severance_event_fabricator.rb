# frozen_string_literal: true

Fabricator(:relationship_severance_event) do
  type { :domain_block }
  target_name { 'example.com' }
end
