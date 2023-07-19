# frozen_string_literal: true

module DatabaseHelper
  def with_read_replica(&block)
    ApplicationRecord.connected_to(role: :reading, prevent_writes: true, &block)
  end

  def with_primary(&block)
    ApplicationRecord.connected_to(role: :writing, &block)
  end
end
