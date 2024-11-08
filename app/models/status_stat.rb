# frozen_string_literal: true

class StatusStat < ApplicationRecord
  belongs_to :status, inverse_of: :status_stat

  before_validation :clamp_untrusted_counts

  MAX_UNTRUSTED_COUNT = 100_000_000

  def replies_count
    [attributes['replies_count'], 0].max
  end

  def reblogs_count
    [attributes['reblogs_count'], 0].max
  end

  def favourites_count
    [attributes['favourites_count'], 0].max
  end

  private

  def clamp_untrusted_counts
    self.untrusted_favourites_count = untrusted_favourites_count.to_i.clamp(0, MAX_UNTRUSTED_COUNT) if untrusted_favourites_count.present?
    self.untrusted_reblogs_count = untrusted_reblogs_count.to_i.clamp(0, MAX_UNTRUSTED_COUNT) if untrusted_reblogs_count.present?
  end
end
