# frozen_string_literal: true

class SoftwareUpdateCheckService < BaseService
  def call
    clean_outdated_updates!
    return unless SoftwareUpdate.check_enabled?

    process_update_notices!(fetch_update_notices)
  end

  private

  def clean_outdated_updates!
    SoftwareUpdate.find_each do |software_update|
      software_update.delete if Mastodon::Version.gem_version >= software_update.gem_version
    rescue ArgumentError
      software_update.delete
    end
  end

  def fetch_update_notices
    Request.new(:get, "#{api_url}?version=#{version}").add_headers('Accept' => 'application/json', 'User-Agent' => 'Mastodon update checker').perform do |res|
      return Oj.load(res.body_with_limit, mode: :strict) if res.code == 200
    end
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Oj::ParseError
    nil
  end

  def api_url
    ENV.fetch('UPDATE_CHECK_URL', 'https://api.joinmastodon.org/update-check')
  end

  def version
    @version ||= Mastodon::Version.to_s.split('+')[0]
  end

  def process_update_notices!(update_notices)
    return if update_notices.blank? || update_notices['updatesAvailable'].blank?

    # Clear notices that are not listed by the update server anymore
    SoftwareUpdate.where.not(version: update_notices['updatesAvailable'].pluck('version')).delete_all

    # Check if any of the notices is new, and issue notifications
    known_versions = SoftwareUpdate.where(version: update_notices['updatesAvailable'].pluck('version')).pluck(:version)
    new_update_notices = update_notices['updatesAvailable'].filter { |notice| known_versions.exclude?(notice['version']) }
    return if new_update_notices.blank?

    new_updates = new_update_notices.map do |notice|
      SoftwareUpdate.create!(version: notice['version'], urgent: notice['urgent'], type: notice['type'], release_notes: notice['releaseNotes'])
    end

    notify_devops!(new_updates)
  end

  def should_notify_user?(user, urgent_version, patch_version)
    case user.settings['notification_emails.software_updates']
    when 'none'
      false
    when 'critical'
      urgent_version
    when 'patch'
      urgent_version || patch_version
    when 'all'
      true
    end
  end

  def notify_devops!(new_updates)
    has_new_urgent_version = new_updates.any?(&:urgent?)
    has_new_patch_version  = new_updates.any?(&:patch_type?)

    User.those_who_can(:view_devops).includes(:account).find_each do |user|
      next unless should_notify_user?(user, has_new_urgent_version, has_new_patch_version)

      if has_new_urgent_version
        AdminMailer.with(recipient: user.account).new_critical_software_updates.deliver_later
      else
        AdminMailer.with(recipient: user.account).new_software_updates.deliver_later
      end
    end
  end
end
