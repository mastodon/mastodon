# frozen_string_literal: true

Fabricator(:severed_relationship) do
  local_account { Fabricate.build(:account) }
  remote_account { Fabricate.build(:account) }
  relationship_severance_event { Fabricate.build(:relationship_severance_event) }
  direction { :active }
end
