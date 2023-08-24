# frozen_string_literal: true

class Vacuum::ApplicationsVacuum
  def perform
    Doorkeeper::Application.where(owner_id: nil)
                           .where.missing(:created_users, :access_tokens, :access_grants)
                           .where(created_at: ...1.day.ago)
                           .in_batches.delete_all
  end
end
