# frozen_string_literal: true

class List < ApplicationRecord
  include Paginable

  PER_ACCOUNT_LIMIT = 50

  enum :replies_policy, { list: 0, followed: 1, none: 2 }, prefix: :show

  belongs_to :account

  has_many :list_accounts, inverse_of: :list, dependent: :destroy
  has_many :accounts, through: :list_accounts

  validates :title, presence: true

  validate :validate_account_lists_limit, on: :create

  before_destroy :clean_feed_manager

  private

  def validate_account_lists_limit
    errors.add(:base, I18n.t('lists.errors.limit')) if account.lists.count >= PER_ACCOUNT_LIMIT
  end

  def clean_feed_manager
    FeedManager.instance.clean_feeds!(:list, [id])
  end
end
