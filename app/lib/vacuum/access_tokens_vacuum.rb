# frozen_string_literal: true

class Vacuum::AccessTokensVacuum
  def perform
    vacuum_revoked_access_tokens!
    vacuum_revoked_access_grants!
  end

  private

  def vacuum_revoked_access_tokens!
    Doorkeeper::AccessToken.where.not(revoked_at: nil).where('revoked_at < NOW()').delete_all
  end

  def vacuum_revoked_access_grants!
    Doorkeeper::AccessGrant.where.not(revoked_at: nil).where('revoked_at < NOW()').delete_all
  end
end
