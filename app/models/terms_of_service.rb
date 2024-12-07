# frozen_string_literal: true

# == Schema Information
#
# Table name: terms_of_services
#
#  id                   :bigint(8)        not null, primary key
#  changelog            :text             default(""), not null
#  notification_sent_at :datetime
#  published_at         :datetime
#  text                 :text             default(""), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class TermsOfService < ApplicationRecord
  scope :published, -> { where.not(published_at: nil).order(published_at: :desc) }
  scope :live, -> { published.limit(1) }
  scope :draft, -> { where(published_at: nil).order(id: :desc).limit(1) }

  validates :text, presence: true
  validates :changelog, presence: true, if: -> { published? }

  def published?
    published_at.present?
  end

  def notification_sent?
    notification_sent_at.present?
  end

  def scope_for_notification
    User.confirmed.joins(:account).merge(Account.without_suspended).where(created_at: (..published_at))
  end
end
