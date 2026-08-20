# frozen_string_literal: true

# == Schema Information
#
# Table name: account_summaries
#
#  language   :string
#  sensitive  :boolean          default(FALSE), not null
#  account_id :bigint(8)        not null, primary key
#

class AccountSummary < ApplicationRecord
  self.primary_key = :account_id

  # Accounts who haven't posted in this long won't be updated
  MAX_STATUS_AGE = 1.week

  belongs_to :account
  has_many :follow_recommendation_suppressions, primary_key: :account_id, foreign_key: :account_id, inverse_of: false, dependent: nil

  scope :safe, -> { where(sensitive: false) }
  scope :localized, ->(locale) { in_order_of(:language, [locale], filter: false) }
  scope :filtered, -> { where.missing(:follow_recommendation_suppressions) }

  def self.refresh
    return unless connection.table_exists?(table_name)

    scope = Account.where(suspended_at: nil, requested_deletion_at: nil, silenced_at: nil, moved_to_account_id: nil, discoverable: true, locked: false)

    # Delete any record that is ineligible
    joins(:account).merge(scope.invert_where).in_batches.delete_all

    # Unless the table is not populated yet, only update accounts who have recently posted
    scope = scope.joins(:account_stat).where(account_stat: { last_status_at: MAX_STATUS_AGE.ago... }) if exists?

    ids_type = ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveModel::Type::BigInteger.new)

    # Update the data in batches
    scope.in_batches do |accounts|
      connection.exec_insert(<<~SQL.squish, nil, [ActiveRecord::Relation::QueryAttribute.new('accounts.id', accounts.ids, ids_type)])
        INSERT INTO account_summaries (account_id, language, sensitive)
          SELECT
            accounts.id AS account_id,
            mode() WITHIN GROUP (ORDER BY language ASC) AS language,
            mode() WITHIN GROUP (ORDER BY sensitive ASC) AS sensitive
          FROM accounts
          CROSS JOIN LATERAL (
            SELECT
              s.language,
              s.sensitive
            FROM (
              SELECT
                statuses.language,
                statuses.sensitive,
                statuses.reblog_of_id
              FROM statuses
              WHERE statuses.account_id = accounts.id
                AND statuses.deleted_at IS NULL
              ORDER BY statuses.id DESC
              LIMIT 1000
            ) s
            WHERE s.reblog_of_id IS NULL
            LIMIT 20
          ) t0
          WHERE accounts.id = ANY($1)
          GROUP BY accounts.id
        ON CONFLICT (account_id) DO UPDATE SET language = EXCLUDED.language, sensitive = EXCLUDED.sensitive
      SQL
    end
  end

  def self.readonly?
    true
  end
end
