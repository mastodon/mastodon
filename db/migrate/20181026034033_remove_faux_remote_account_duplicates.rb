class RemoveFauxRemoteAccountDuplicates < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  class StreamEntry < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account, inverse_of: :stream_entries
  end

  class Status < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account, inverse_of: :statuses
    has_many :favourites, inverse_of: :status, dependent: :destroy
    has_many :mentions, dependent: :destroy, inverse_of: :status
  end

  class Favourite < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account, inverse_of: :favourites
    belongs_to :status,  inverse_of: :favourites
  end

  class Mention < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account, inverse_of: :mentions
    belongs_to :status
  end

  class Notification < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    belongs_to :account, optional: true
    belongs_to :from_account, class_name: 'Account', optional: true
    belongs_to :activity, polymorphic: true, optional: true
  end

  class Account < ApplicationRecord
    # Dummy class, to make migration possible across version changes
    has_many :stream_entries, inverse_of: :account, dependent: :destroy
    has_many :statuses, inverse_of: :account, dependent: :destroy
    has_many :favourites, inverse_of: :account, dependent: :destroy
    has_many :mentions, inverse_of: :account, dependent: :destroy
    has_many :notifications, inverse_of: :account, dependent: :destroy
  end

  def up
    local_domain = Rails.configuration.x.local_domain

    # Just a safety measure to ensure that under no circumstance
    # we will query `domain IS NULL` because that would return
    # actually local accounts, the originals
    return if local_domain.nil?

    Account.where(domain: local_domain).in_batches.destroy_all
  end

  def down; end
end
