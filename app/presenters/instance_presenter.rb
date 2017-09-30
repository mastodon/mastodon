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

  def user_count
    Rails.cache.fetch('user_count') { User.confirmed.count }
  end

  def status_count
    Rails.cache.fetch('local_status_count') { Account.local.sum(:statuses_count) }
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Account.distinct.count(:domain) }
  end

  def active_user_count_30d
    Rails.cache.fetch('active_user_count_30d') { User.confirmed.where('current_sign_in_at >= ?', 30.days.ago).count }
  end

  def active_user_count_14d
    Rails.cache.fetch('active_user_count_14d') { User.confirmed.where('current_sign_in_at >= ?', 14.days.ago).count }
  end

  def active_user_count_7d
    Rails.cache.fetch('active_user_count_7d') { User.confirmed.where('current_sign_in_at >= ?', 7.days.ago).count }
  end

  def active_user_count_1d
    Rails.cache.fetch('active_user_count_1d') { User.confirmed.where('current_sign_in_at >= ?', 1.day.ago).count }
  end

  def active_user_count_1h
    Rails.cache.fetch('active_user_count_1h') { User.confirmed.where('current_sign_in_at >= ?', 1.hour.ago).count }
  end

  def first_user_created_at
    Rails.cache.fetch('first_user_created_at') { User.first.created_at }
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
