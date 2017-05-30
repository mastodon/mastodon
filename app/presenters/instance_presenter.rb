# frozen_string_literal: true

class InstancePresenter
  delegate(
    :closed_registrations_message,
    :contact_email,
    :site_contact_email,
    :site_description,
    :site_extended_description,
    to: Setting
  )

  def contact_account
    Account.find_local(Setting.site_contact_username)
  end

  def user_count
    Rails.cache.fetch('user_count') { User.confirmed.count }
  end

  def status_count
    Rails.cache.fetch('local_status_count') { Status.local.count }
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Account.distinct.count(:domain) }
  end

  def open_registrations
    return false unless Setting.open_registrations
    return true unless Setting.max_users
    user_count < Setting.max_users
  end

  def version_number
    Mastodon::Version
  end
end
