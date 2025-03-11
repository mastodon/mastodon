# frozen_string_literal: true

module Fasp
  DATA_CATEGORIES = %w(account content).freeze

  def self.table_name_prefix
    'fasp_'
  end

  def self.capability_enabled?(capability_name)
    Mastodon::Feature.fasp_enabled? &&
      Provider.with_capability(capability_name).any?
  end
end
