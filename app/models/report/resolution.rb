# frozen_string_literal: true

module Report::Resolution
  extend ActiveSupport::Concern

  included do
    scope :resolved, -> { where.not(action_taken_at: nil) }
    scope :unresolved, -> { where(action_taken_at: nil) }
  end

  def action_taken?
    action_taken_at?
  end
  alias action_taken action_taken?

  def resolve!(acting_account)
    update!(action_taken_at: Time.now.utc, action_taken_by_account: acting_account)
  end

  def unresolve!
    update!(action_taken_at: nil, action_taken_by_account_id: nil)
  end

  def unresolved?
    !action_taken?
  end

  def unresolved_siblings?
    Report.excluding(self).where(target_account_id:).unresolved.exists?
  end
end
