# frozen_string_literal: true

# == Schema Information
#
# Table name: terms_of_services
#
#  id                   :bigint(8)        not null, primary key
#  changelog            :text             default(""), not null
#  effective_date       :date
#  notification_sent_at :datetime
#  published_at         :datetime
#  text                 :text             default(""), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class TermsOfService < ApplicationRecord
  scope :published, -> { where.not(published_at: nil).order(Arel.sql('coalesce(effective_date, published_at) DESC')) }
  scope :live, -> { published.where('effective_date IS NULL OR effective_date < now()') }
  scope :upcoming, -> { published.reorder(effective_date: :asc).where('effective_date IS NOT NULL AND effective_date > now()') }
  scope :draft, -> { where(published_at: nil).order(id: :desc) }

  validates :text, presence: true
  validates :changelog, :effective_date, presence: true, if: -> { published? }
  validates :effective_date, uniqueness: true

  validate :effective_date_cannot_be_in_the_past

  NOTIFICATION_ACTIVITY_CUTOFF = 1.year.freeze

  def self.current
    live.first || upcoming.first # For the case when none of the published terms have become effective yet
  end

  def published?
    published_at.present?
  end

  def effective?
    published? && effective_date&.past?
  end

  def succeeded_by
    TermsOfService.published.where(effective_date: (effective_date..)).where.not(id: id).first
  end

  def notification_sent?
    notification_sent_at.present?
  end

  def base_user_scope
    User.confirmed.where(created_at: ..published_at).joins(:account)
  end

  def email_notification_cutoff
    published_at - NOTIFICATION_ACTIVITY_CUTOFF
  end

  def scope_for_interstitial
    base_user_scope.merge(Account.suspended).or(base_user_scope.where(current_sign_in_at: [nil, ...email_notification_cutoff]))
  end

  def scope_for_notification
    base_user_scope.merge(Account.without_suspended).where(current_sign_in_at: email_notification_cutoff...)
  end

  private

  def effective_date_cannot_be_in_the_past
    return if effective_date.blank?

    min_date = TermsOfService.live.pick(:effective_date) || Time.zone.today

    errors.add(:effective_date, :too_soon, date: min_date) if effective_date < min_date
  end
end
