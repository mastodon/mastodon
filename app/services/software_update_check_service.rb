# frozen_string_literal: true

class SoftwareUpdateCheckService < BaseService
  def call
    clean_outdated_updates!
    clean_outdated_deprecations!
    return unless SoftwareUpdate.check_enabled?

    json = fetch_update_notices
    process_update_notices!(json&.fetch('updatesAvailable', nil))
    process_deprecation_notice!(json&.fetch('currentVersion', nil))
  end

  private

  def clean_outdated_updates!
    SoftwareUpdate.find_each do |software_update|
      software_update.delete if software_update.outdated?
    rescue ArgumentError
      software_update.delete
    end
  end

  def clean_outdated_deprecations!
    SoftwareDeprecation.clear_irrelevant_branches!
  end

  def fetch_update_notices
    Request.new(:get, "#{api_url}?version=#{version}").add_headers('Accept' => 'application/json', 'User-Agent' => 'Mastodon update checker').perform do |res|
      return JSON.parse(res.body_with_limit) if res.code == 200
    end
  rescue *Mastodon::HTTP_CONNECTION_ERRORS, JSON::ParserError
    nil
  end

  def api_url
    Rails.configuration.x.mastodon.software_update_url
  end

  def version
    @version ||= Mastodon::Version.to_s.split('+')[0]
  end

  def process_update_notices!(update_notices)
    return if update_notices.blank?

    # Clear notices that are not listed by the update server anymore
    SoftwareUpdate.where.not(version: update_notices.pluck('version')).delete_all

    # Check if any of the notices is new, and issue notifications
    known_versions = SoftwareUpdate.where(version: update_notices.pluck('version')).pluck(:version)
    new_update_notices = update_notices.filter { |notice| known_versions.exclude?(notice['version']) }
    return if new_update_notices.blank?

    SoftwareUpdate.upsert_all(update_notices.map do |notice|
      { version: notice['version'], urgent: notice['urgent'], type: notice['type'], release_notes: notice['releaseNotes'], end_of_support: notice['endOfSupport']&.to_date }
    end, unique_by: :version)

    new_updates = SoftwareUpdate.where(version: new_update_notices.pluck('version')).to_a

    notify_devops!(new_updates)
  end

  def process_deprecation_notice!(current_version)
    return if current_version.blank? || current_version['endOfSupport'].blank?

    deprecation_notice = SoftwareDeprecation
      .create_with(warning_issued: :none, end_of_support: current_version['endOfSupport'].to_date)
      .find_or_create_by(branch: SoftwareDeprecation.current_branch)

    deprecation_notice.update(end_of_support: current_version['endOfSupport'].to_date)

    notify_of_end_of_support!(deprecation_notice)
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

  def should_notify_about_end_of_support?(user)
    user.settings['notification_emails.end_of_support']
  end

  def send_notification_for_end_of_support_warning!(deprecation_notice, warning_type)
    return if deprecation_notice.warning_issued == warning_type

    User.those_who_can(:view_devops).includes(:account).find_each do |user|
      next unless should_notify_about_end_of_support?(user)

      AdminMailer.with(recipient: user.account).public_send("end_of_support_#{warning_type}").deliver_later
    end

    deprecation_notice.update!(warning_issued: warning_type)
  end

  def notify_of_end_of_support!(deprecation_notice)
    if deprecation_notice.end_of_support.past?
      send_notification_for_end_of_support_warning!(deprecation_notice, 'out_of_support_warning')
    elsif deprecation_notice.end_of_support < 2.weeks.from_now
      send_notification_for_end_of_support_warning!(deprecation_notice, 'two_weeks_warning')
    elsif deprecation_notice.end_of_support < 3.months.from_now
      send_notification_for_end_of_support_warning!(deprecation_notice, 'three_months_warning')
    end
  end
end
