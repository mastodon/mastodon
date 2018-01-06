# frozen_string_literal: true

class InstancePresenter
  delegate(
    :closed_registrations_message,
    :site_contact_email,
    :open_registrations,
    :site_title,
    :site_description,
    :site_extended_description,
    :site_terms,
    to: Setting
  )

  def contact_account
    Account.find_local(Setting.site_contact_username)
  end

  def week_id
    0.weeks.ago.to_date.cweek
  end
  
  def user_count
    Redis.current.pfcount("activity:logins:#{week_id}")
  end

  def status_count
    Redis.current.get("activity:statuses:local:#{week_id}")
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Account.distinct.count(:domain) }
  end

  def version_number
    Mastodon::Version
  end

  def source_url
    Mastodon::Version.source_url
  end

  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail') { SiteUpload.find_by(var: 'thumbnail') }
  end
end
