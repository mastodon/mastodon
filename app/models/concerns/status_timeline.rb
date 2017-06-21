# frozen_string_literal: true

module StatusTimeline
  extend ActiveSupport::Concern

  class_methods do
    def as_home_timeline(account, limit: nil, max_id: nil, since_id: nil)
      mention_status_ids = Mention.select(:status_id).where(account: account)
      if limit.present?
        mention_status_ids = mention_status_ids.where('status_ids < ?', max_id) if max_id.present?
        mention_status_ids = mention_status_ids.where('status_ids > ?', since_id) if since_id.present?
        mention_status_ids = mention_status_ids.limit(limit)
      end

      # 'references' is a workaround for the following issue:
      # Inconsistent results with #or in ActiveRecord::Relation with respect to documentation Issue #24055 rails/rails
      # https://github.com/rails/rails/issues/24055
      statuses = where.not(visibility: :direct)
        .or(where(id: mention_status_ids))
        .where(follows: { account_id: account })
        .or(references(:follows).where(account: account))
        .left_outer_joins(account: :followers).group(:id)

      limit.nil? ? statuses : statuses.paginate_by_max_id(limit, max_id, since_id)
    end

    def as_public_timeline(account: nil, local_only: false, limit: nil, max_id: nil, since_id: nil)
      query = timeline_scope(local_only).without_replies

      statuses = apply_timeline_filters(query, account, local_only)
      limit.nil? ? statuses : statuses.paginate_by_max_id(limit, max_id, since_id)
    end

    def as_tag_timeline(tag, account: nil, local_only: false, limit: nil, max_id: nil, since_id: nil)
      query = timeline_scope(local_only).tagged_with(tag)

      statuses = apply_timeline_filters(query, account, local_only)
      limit.nil? ? statuses : statuses.paginate_by_max_id(limit, max_id, since_id)
    end

    def as_outbox_timeline(account, limit: nil, max_id: nil, since_id: nil)
      statuses = where(account: account, visibility: :public)
      limit.nil? ? statuses : statuses.paginate_by_max_id(limit, max_id, since_id)
    end

    private

    def timeline_scope(local_only = false)
      starting_scope = local_only ? Status.local_only : Status
      starting_scope
        .with_public_visibility
        .without_reblogs
    end

    def apply_timeline_filters(query, account, local_only)
      if account.nil?
        filter_timeline_default(query)
      else
        filter_timeline_for_account(query, account, local_only)
      end
    end

    def filter_timeline_for_account(query, account, local_only)
      query = query.not_excluded_by_account(account)
      query = query.not_domain_blocked_by_account(account) unless local_only
      query = query.not_in_filtered_languages(account) if account.filtered_languages.present?
      query.merge(account_silencing_filter(account))
    end

    def filter_timeline_default(query)
      query.excluding_silenced_accounts
    end

    def account_silencing_filter(account)
      if account.silenced?
        including_silenced_accounts
      else
        excluding_silenced_accounts
      end
    end
  end
end
