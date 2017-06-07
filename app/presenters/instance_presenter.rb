# frozen_string_literal: true

class InstancePresenter
  delegate(
    :closed_registrations_message,
    :site_contact_email,
    :open_registrations,
    :site_description,
    :site_extended_description,
    to: Setting
  )

  def contact_account
    Account.find_local(Setting.site_contact_username)
  end

  def user_count
    Rails.cache.fetch('user_count', expires_in: cache_expires) { User.confirmed.count }
  end

  def status_count
    Rails.cache.fetch('local_status_count', expires_in: cache_expires) { Status.local.count }
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count', expires_in: cache_expires) { Account.distinct.count(:domain) }
  end

  def version_number
    Mastodon::Version
  end

  private

  def cache_expires
    10.minutes
  end
end
