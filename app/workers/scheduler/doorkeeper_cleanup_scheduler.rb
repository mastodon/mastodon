# frozen_string_literal: true

class Scheduler::DoorkeeperCleanupScheduler
  include Sidekiq::Worker

  def perform
    Doorkeeper::AccessToken.where('revoked_at IS NOT NULL').where('revoked_at < NOW()').delete_all
    Doorkeeper::AccessGrant.where('revoked_at IS NOT NULL').where('revoked_at < NOW()').delete_all
  end
end
