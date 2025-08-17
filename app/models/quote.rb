# frozen_string_literal: true

# == Schema Information
#
# Table name: quotes
#
#  id                :bigint(8)        not null, primary key
#  activity_uri      :string
#  approval_uri      :string
#  legacy            :boolean          default(FALSE), not null
#  state             :integer          default("pending"), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  account_id        :bigint(8)        not null
#  quoted_account_id :bigint(8)
#  quoted_status_id  :bigint(8)
#  status_id         :bigint(8)        not null
#
class Quote < ApplicationRecord
  include Paginable

  has_one :notification, as: :activity, dependent: :destroy

  BACKGROUND_REFRESH_INTERVAL = 1.week.freeze
  REFRESH_DEADLINE = 6.hours

  enum :state,
       { pending: 0, accepted: 1, rejected: 2, revoked: 3 },
       validate: true

  belongs_to :status
  belongs_to :quoted_status, class_name: 'Status', optional: true

  belongs_to :account
  belongs_to :quoted_account, class_name: 'Account', optional: true

  before_validation :set_accounts
  before_validation :set_activity_uri, only: :create, if: -> { account.local? && quoted_account&.remote? }
  validates :activity_uri, presence: true, if: -> { account.local? && quoted_account&.remote? }
  validates :approval_uri, absence: true, if: -> { quoted_account&.local? }
  validate :validate_visibility

  def accept!
    update!(state: :accepted)
  end

  def reject!
    if accepted?
      update!(state: :revoked)
    elsif !revoked?
      update!(state: :rejected)
    end
  end

  def acceptable?
    accepted? || !legacy?
  end

  def ensure_quoted_access
    status.mentions.create!(account: quoted_account, silent: true)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    nil
  end

  def schedule_refresh_if_stale!
    return unless quoted_status_id.present? && approval_uri.present? && updated_at <= BACKGROUND_REFRESH_INTERVAL.ago

    ActivityPub::QuoteRefreshWorker.perform_in(rand(REFRESH_DEADLINE), id)
  end

  private

  def set_accounts
    self.account = status.account
    self.quoted_account = quoted_status&.account
  end

  def validate_visibility
    return if account_id == quoted_account_id || quoted_status.nil? || quoted_status.distributable?

    errors.add(:quoted_status_id, :visibility_mismatch)
  end

  def set_activity_uri
    self.activity_uri = [ActivityPub::TagManager.instance.uri_for(account), '/quote_requests/', SecureRandom.uuid].join
  end
end
