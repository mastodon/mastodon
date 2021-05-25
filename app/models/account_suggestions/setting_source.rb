# frozen_string_literal: true

class AccountSuggestions::SettingSource < AccountSuggestions::Source
  def key
    :staff
  end

  def get(account, skip_account_ids: [], limit: 40)
    return [] unless setting_enabled?

    as_ordered_suggestions(
      scope(account).where(setting_to_where_condition).where.not(id: skip_account_ids),
      usernames_and_domains
    ).take(limit)
  end

  def remove(_account, _target_account_id)
    nil
  end

  private

  def scope(account)
    Account.searchable
           .followable_by(account)
           .not_excluded_by_account(account)
           .not_domain_blocked_by_account(account)
           .where(locked: false)
           .where.not(id: account.id)
  end

  def usernames_and_domains
    @usernames_and_domains ||= setting_to_usernames_and_domains
  end

  def setting_enabled?
    setting.present?
  end

  def setting_to_where_condition
    usernames_and_domains.map do |(username, domain)|
      Arel::Nodes::Grouping.new(
        Account.arel_table[:username].lower.eq(username.downcase).and(
          Account.arel_table[:domain].lower.eq(domain&.downcase)
        )
      )
    end.reduce(:or)
  end

  def setting_to_usernames_and_domains
    setting.split(',').map do |str|
      username, domain = str.strip.gsub(/\A@/, '').split('@', 2)
      domain           = nil if TagManager.instance.local_domain?(domain)

      next if username.blank?

      [username, domain]
    end.compact
  end

  def setting
    Setting.bootstrap_timeline_accounts
  end

  def to_ordered_list_key(account)
    [account.username, account.domain]
  end
end
