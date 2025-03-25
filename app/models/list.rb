# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id             :bigint(8)        not null, primary key
#  description    :text             default(""), not null
#  exclusive      :boolean          default(FALSE), not null
#  replies_policy :integer          default("list"), not null
#  title          :string           default(""), not null
#  type           :integer          default("private_list"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  account_id     :bigint(8)        not null
#

class List < ApplicationRecord
  self.inheritance_column = nil

  include Paginable

  PER_ACCOUNT_LIMIT = 50

  enum :replies_policy, { list: 0, followed: 1, none: 2 }, prefix: :show
  enum :type, { private_list: 0, public_list: 1 }

  belongs_to :account

  has_many :list_accounts, inverse_of: :list, dependent: :destroy
  has_many :accounts, through: :list_accounts
  has_many :active_accounts, -> { merge(ListAccount.active) }, through: :list_accounts, source: :account

  validates :title, presence: true, length: { maximum: 30 }
  validates :description, length: { maximum: 160 }

  validate :validate_account_lists_limit, on: :create

  before_destroy :clean_feed_manager

  def slug
    title.parameterize
  end

  def to_url_param
    { id:, slug: }
  end

  private

  def validate_account_lists_limit
    errors.add(:base, I18n.t('lists.errors.limit')) if account.owned_lists.count >= PER_ACCOUNT_LIMIT
  end

  def clean_feed_manager
    FeedManager.instance.clean_feeds!(:list, [id])
  end
end
