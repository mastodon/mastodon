# frozen_string_literal: true

class Vacuum::AccessTokensVacuum
  def perform
    vacuum_revoked_access_tokens!
    vacuum_revoked_access_grants!
  end

  private

  def vacuum_revoked_access_tokens!
    OAuth::AccessToken.expired.in_batches.delete_all
    OAuth::AccessToken.revoked.in_batches.delete_all
  end

  def vacuum_revoked_access_grants!
    OAuth::AccessGrant.expired.in_batches.delete_all
    OAuth::AccessGrant.revoked.in_batches.delete_all
  end
end
