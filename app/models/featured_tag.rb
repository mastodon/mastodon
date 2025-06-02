# frozen_string_literal: true

# == Schema Information
#
# Table name: featured_tags
#
#  id             :bigint(8)        not null, primary key
#  account_id     :bigint(8)        not null
#  tag_id         :bigint(8)        not null
#  statuses_count :bigint(8)        default(0), not null
#  last_status_at :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  name           :string
#

class FeaturedTag < ApplicationRecord
  belongs_to :account, inverse_of: :featured_tags
  belongs_to :tag, inverse_of: :featured_tags, optional: true # Set after validation

  validates :name, presence: true, on: :create, if: -> { tag_id.nil? }
  validates :name, format: { with: Tag::HASHTAG_NAME_RE }, on: :create, allow_blank: true
  validates :tag_id, uniqueness: { scope: :account_id }

  validate :validate_featured_tags_limit, on: :create

  normalizes :name, with: ->(name) { name.strip.delete_prefix('#') }

  scope :by_name, ->(name) { joins(:tag).where(tag: { name: HashtagNormalizer.new.normalize(name) }) }

  before_validation :set_tag

  before_create :reset_data

  LIMIT = 10

  def sign?
    true
  end

  def display_name
    attributes['name'] || tag.display_name
  end

  def increment(timestamp)
    update(statuses_count: statuses_count + 1, last_status_at: timestamp)
  end

  def decrement(deleted_status)
    if statuses_count <= 1
      update(statuses_count: 0, last_status_at: nil)
    elsif last_status_at.present? && last_status_at > deleted_status.created_at
      update(statuses_count: statuses_count - 1)
    else
      # Fetching the latest status creation time can be expensive, so only perform it
      # if we know we are deleting the latest status using this tag
      update(statuses_count: statuses_count - 1, last_status_at: visible_tagged_account_statuses.where(id: ...deleted_status.id).pick(:created_at))
    end
  end

  private

  def set_tag
    if tag.nil?
      self.tag = Tag.find_or_create_by_names(name)&.first
    elsif tag&.new_record?
      tag.save
    end
  end

  def reset_data
    self.statuses_count = visible_tagged_account_statuses.count
    self.last_status_at = visible_tagged_account_statuses.pick(:created_at)
  end

  def validate_featured_tags_limit
    return unless account.local?

    errors.add(:base, I18n.t('featured_tags.errors.limit')) if account.featured_tags.count >= LIMIT
  end

  def visible_tagged_account_statuses
    account.statuses.distributable_visibility.tagged_with(tag)
  end
end
