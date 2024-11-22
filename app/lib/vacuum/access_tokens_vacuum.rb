# frozen_string_literal: true

class Vacuum::AccessTokensVacuum
  def perform
    vacuum_revoked_access_tokens!
    vacuum_revoked_access_grants!
  end

  private

  def vacuum_revoked_access_tokens!
    Doorkeeper::AccessToken.expired.in_batches.delete_all
    Doorkeeper::AccessToken.revoked.in_batches.delete_all
  end

  def vacuum_revoked_access_grants!
    Doorkeeper::AccessGrant.expired.in_batches.delete_all
    Doorkeeper::AccessGrant.revoked.in_batches.delete_all
  end
end
