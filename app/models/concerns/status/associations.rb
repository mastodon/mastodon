# frozen_string_literal: true

module Status::Associations
  extend ActiveSupport::Concern

  included do
    belongs_to :application, class_name: 'Doorkeeper::Application', optional: true

    belongs_to :account, inverse_of: :statuses
    belongs_to :in_reply_to_account, class_name: 'Account', optional: true
    belongs_to :conversation, optional: true
    belongs_to :preloadable_poll, class_name: 'Poll', foreign_key: 'poll_id', optional: true, inverse_of: false

    with_options class_name: 'Status', optional: true do
      belongs_to :thread, foreign_key: 'in_reply_to_id', inverse_of: :replies
      belongs_to :reblog, foreign_key: 'reblog_of_id', inverse_of: :reblogs
    end

    has_many :favourites, inverse_of: :status, dependent: :destroy
    has_many :bookmarks, inverse_of: :status, dependent: :destroy
    has_many :reblogs, foreign_key: 'reblog_of_id', class_name: 'Status', inverse_of: :reblog, dependent: :destroy
    has_many :reblogged_by_accounts, through: :reblogs, class_name: 'Account', source: :account
    has_many :replies, foreign_key: 'in_reply_to_id', class_name: 'Status', inverse_of: :thread, dependent: nil
    has_many :mentions, dependent: :destroy, inverse_of: :status
    has_many :mentioned_accounts, through: :mentions, source: :account, class_name: 'Account'
    has_many :media_attachments, dependent: :nullify

    # The `dependent` option is enabled by the initial `mentions` association declaration
    has_many :active_mentions, -> { active }, class_name: 'Mention', inverse_of: :status # rubocop:disable Rails/HasManyOrHasOneDependent

    # Those associations are used for the private search index
    has_many :local_mentioned, -> { merge(Account.local) }, through: :active_mentions, source: :account
    has_many :local_favorited, -> { merge(Account.local) }, through: :favourites, source: :account
    has_many :local_reblogged, -> { merge(Account.local) }, through: :reblogs, source: :account
    has_many :local_bookmarked, -> { merge(Account.local) }, through: :bookmarks, source: :account

    has_and_belongs_to_many :tags

    has_one :preview_cards_status, inverse_of: :status, dependent: :delete

    has_one :notification, as: :activity, dependent: :destroy
    has_one :status_stat, inverse_of: :status, dependent: nil
    has_one :poll, inverse_of: :status, dependent: :destroy
    has_one :trend, class_name: 'StatusTrend', inverse_of: :status, dependent: nil
  end
end
