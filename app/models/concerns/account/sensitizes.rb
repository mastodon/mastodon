# frozen_string_literal: true

module Account::Sensitizes
  extend ActiveSupport::Concern

  included do
    scope :sensitized, -> { where.not(sensitized_at: nil) }
  end

  def sensitized?
    sensitized_at.present?
  end

  def sensitize!(date = Time.now.utc)
    update!(sensitized_at: date)
  end

  def unsensitize!
    update!(sensitized_at: nil)
  end
end
