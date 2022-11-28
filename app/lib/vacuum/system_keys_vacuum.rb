# frozen_string_literal: true

module Vacuum
  class SystemKeysVacuum
    def perform
      vacuum_expired_system_keys!
    end

    private

    def vacuum_expired_system_keys!
      SystemKey.expired.in_batches(&:delete_all)
    end
  end
end
