# frozen_string_literal: true

module Account::Silences
  extend ActiveSupport::Concern

  included do
    scope :silenced, -> { where.not(silenced_at: nil) }
    scope :without_silenced, -> { where(silenced_at: nil) }
  end

  def silenced?
    silenced_at.present?
  end

  def silence!(date = Time.now.utc)
    update!(silenced_at: date)
  end

  def unsilence!
    update!(silenced_at: nil)
  end
end
