# frozen_string_literal: true

class Vacuum::AccessTokensVacuum
  def perform
    vacuum_revoked_access_tokens!
    vacuum_revoked_access_grants!
  end

  private

  def vacuum_revoked_access_tokens!
    Doorkeeper::AccessToken.where.not(expires_in: nil).where('created_at + make_interval(secs => expires_in) < NOW()').in_batches.delete_all
    Doorkeeper::AccessToken.where.not(revoked_at: nil).where('revoked_at < NOW()').in_batches.delete_all
  end

  def vacuum_revoked_access_grants!
    Doorkeeper::AccessGrant.where.not(expires_in: nil).where('created_at + make_interval(secs => expires_in) < NOW()').in_batches.delete_all
    Doorkeeper::AccessGrant.where.not(revoked_at: nil).where('revoked_at < NOW()').in_batches.delete_all
  end
end
