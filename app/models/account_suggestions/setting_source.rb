# frozen_string_literal: true

class AccountSuggestions::SettingSource < AccountSuggestions::Source
  def get(account, limit: DEFAULT_LIMIT)
    if setting_enabled?
      base_account_scope(account).merge(setting_to_where_condition).limit(limit).pluck(:id).zip([key].cycle)
    else
      []
    end
  end

  private

  def key
    :featured
  end

  def usernames_and_domains
    @usernames_and_domains ||= setting_to_usernames_and_domains
  end

  def setting_enabled?
    setting.present?
  end

  def setting_to_where_condition
    usernames_and_domains.map do |(username, domain)|
      Account
        .with_username(username)
        .with_domain(domain)
    end.reduce(:or)
  end

  def setting_to_usernames_and_domains
    setting.split(',').filter_map do |str|
      username, domain = str.strip.gsub(/\A@/, '').split('@', 2)
      domain           = nil if TagManager.instance.local_domain?(domain)

      next if username.blank?

      [username.downcase, domain&.downcase]
    end
  end

  def setting
    Setting.bootstrap_timeline_accounts
  end
end
