# frozen_string_literal: true

class OAuth::AccessGrant < ApplicationRecord
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessGrant

  scope :expired, -> { where.not(expires_in: nil).where('created_at + MAKE_INTERVAL(secs => expires_in) < NOW()') }
  scope :revoked, -> { where.not(revoked_at: nil).where(revoked_at: ...Time.now.utc) }
end
