# frozen_string_literal: true

class Vacuum::SystemKeysVacuum
  def perform
    vacuum_expired_system_keys!
  end

  private

  def vacuum_expired_system_keys!
    SystemKey.expired.delete_all
  end
end
