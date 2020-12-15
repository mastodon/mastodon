# frozen_string_literal: true

class InstancePresenter
  delegate(
    :site_contact_email,
    :site_title,
    :site_short_description,
    :site_description,
    :site_extended_description,
    :site_terms,
    :closed_registrations_message,
    to: Setting
  )

  def contact_account
    Account.find_local(Setting.site_contact_username.strip.gsub(/\A@/, ''))
  end

  def user_count
    Rails.cache.fetch('user_count') { User.confirmed.joins(:account).merge(Account.without_suspended).count }
  end

  def active_user_count(weeks = 4)
    Rails.cache.fetch("active_user_count/#{weeks}") { Redis.current.pfcount(*(0...weeks).map { |i| "activity:logins:#{i.weeks.ago.utc.to_date.cweek}" }) }
  end

  def status_count
    Rails.cache.fetch('local_status_count') { Account.local.joins(:account_stat).sum('account_stats.statuses_count') }.to_i
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Instance.count }
  end

  def sample_accounts
    Rails.cache.fetch('sample_accounts', expires_in: 12.hours) { Account.local.discoverable.popular.limit(3) }
  end

  def version_number
    Mastodon::Version
  end

  def commit_hash
    current_release_file = Pathname.new('CURRENT_RELEASE').expand_path
    if current_release_file.file?
      IO.read(current_release_file).strip!
    else
      ''
    end
  end

  def source_url
    Mastodon::Version.source_url
  end

  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail') { SiteUpload.find_by(var: 'thumbnail') }
  end

  def hero
    @hero ||= Rails.cache.fetch('site_uploads/hero') { SiteUpload.find_by(var: 'hero') }
  end

  def mascot
    @mascot ||= Rails.cache.fetch('site_uploads/mascot') { SiteUpload.find_by(var: 'mascot') }
  end
end
