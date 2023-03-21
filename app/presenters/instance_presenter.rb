# frozen_string_literal: true

class InstancePresenter < ActiveModelSerializers::Model
  attributes :domain, :title, :version, :source_url,
             :description, :languages, :rules, :contact

  class ContactPresenter < ActiveModelSerializers::Model
    attributes :email, :account

    def email
      Setting.site_contact_email
    end

    def account
      username, domain = Setting.site_contact_username.strip.gsub(/\A@/, '').split('@', 2)
      domain = nil if TagManager.instance.local_domain?(domain)
      Account.find_remote(username, domain) if username.present?
    end
  end

  def contact
    ContactPresenter.new
  end

  def description
    Setting.site_short_description
  end

  def extended_description
    Setting.site_extended_description
  end

  def privacy_policy
    Setting.site_terms
  end

  def status_page_url
    Setting.status_page_url
  end

  def domain
    Rails.configuration.x.local_domain
  end

  def title
    Setting.site_title
  end

  def languages
    [I18n.default_locale]
  end

  def rules
    Rule.ordered
  end

  def user_count
    Rails.cache.fetch('user_count') { User.confirmed.joins(:account).merge(Account.without_suspended).count }
  end

  def active_user_count(num_weeks = 4)
    Rails.cache.fetch("active_user_count/#{num_weeks}") { ActivityTracker.new('activity:logins', :unique).sum(num_weeks.weeks.ago) }
  end

  def status_count
    Rails.cache.fetch('local_status_count') { Account.local.joins(:account_stat).sum('account_stats.statuses_count') }.to_i
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Instance.count }
  end

  def version
    Mastodon::Version.to_s
  end

  def source_url
    Mastodon::Version.source_url
  end

  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail') { SiteUpload.find_by(var: 'thumbnail') }
  end

  def mascot
    @mascot ||= Rails.cache.fetch('site_uploads/mascot') { SiteUpload.find_by(var: 'mascot') }
  end
end
