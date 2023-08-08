# frozen_string_literal: true

class InstancesIndex < Chewy::Index
  settings index: index_preset(refresh_interval: '30s')

  index_scope ::Instance.searchable

  root date_detection: false do
    field :domain, type: 'text', index_prefixes: { min_chars: 1 }
    field :accounts_count, type: 'long'
  end
end
