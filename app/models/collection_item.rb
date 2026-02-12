# frozen_string_literal: true

# == Schema Information
#
# Table name: collection_items
#
#  id                        :bigint(8)        not null, primary key
#  activity_uri              :string
#  approval_last_verified_at :datetime
#  approval_uri              :string
#  object_uri                :string
#  position                  :integer          default(1), not null
#  state                     :integer          default("pending"), not null
#  uri                       :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  account_id                :bigint(8)
#  collection_id             :bigint(8)        not null
#
class CollectionItem < ApplicationRecord
  belongs_to :collection, counter_cache: :item_count
  belongs_to :account, optional: true

  enum :state,
       { pending: 0, accepted: 1, rejected: 2, revoked: 3 },
       validate: true

  delegate :local?, :remote?, to: :collection

  validates :position, numericality: { only_integer: true, greater_than: 0 }
  validates :activity_uri, presence: true, if: :local_item_with_remote_account?
  validates :approval_uri, absence: true, unless: :local?
  validates :account, presence: true, if: :accepted?
  validates :object_uri, presence: true, if: -> { account.nil? }
  validates :uri, presence: true, if: :remote?

  before_validation :set_position, on: :create

  scope :ordered, -> { order(position: :asc) }
  scope :with_accounts, -> { includes(account: [:account_stat, :user]) }
  scope :not_blocked_by, ->(account) { where.not(accounts: { id: account.blocking }) }

  def local_item_with_remote_account?
    local? && account&.remote?
  end

  def object_type
    :featured_item
  end

  private

  def set_position
    return if position_changed?

    self.position = self.class.where(collection_id:).maximum(:position).to_i + 1
  end
end
