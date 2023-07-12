# frozen_string_literal: true

module DatabaseHelper
  def with_read_replica(&block)
    ApplicationRecord.connected_to(role: :read, prevent_writes: true, &block)
  end

  def with_primary(&block)
    ApplicationRecord.connected_to(role: :primary, &block)
  end
end
