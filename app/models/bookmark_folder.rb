# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmark_folders
#
#  id         :bigint(8)        not null, primary key
#  title      :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#

class BookmarkFolder < ApplicationRecord
  include Paginable

  PER_ACCOUNT_LIMIT = 50
  TITLE_LENGTH_LIMIT = 256

  belongs_to :account

  has_many :bookmarks, foreign_key: 'folder_id', dependent: :nullify, inverse_of: :bookmark_folder

  validates :title, presence: true, length: { maximum: TITLE_LENGTH_LIMIT }

  validate :validate_account_folders_limit, on: :create

  private

  def validate_account_folders_limit
    errors.add(:base, I18n.t('bookmark_folders.errors.limit')) if account.bookmark_folders.count >= PER_ACCOUNT_LIMIT
  end
end
