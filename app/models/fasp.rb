# frozen_string_literal: true

module Fasp
  DATA_CATEGORIES = %w(account content).freeze

  def self.table_name_prefix
    'fasp_'
  end
end
