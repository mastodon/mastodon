# frozen_string_literal: true

class Admin::SystemCheck::SoftwareVersionCheck < Admin::SystemCheck::BaseCheck
  include RoutingHelper

  def skip?
    !current_user.can?(:view_devops) || !SoftwareUpdate.check_enabled?
  end

  def pass?
    software_updates.empty?
  end

  def message
    if software_updates.any?(&:urgent?)
      Admin::SystemCheck::Message.new(:software_version_critical_check, nil, admin_software_updates_path, true)
    else
      Admin::SystemCheck::Message.new(:software_version_patch_check, nil, admin_software_updates_path)
    end
  end

  private

  def software_updates
    @software_updates ||= SoftwareUpdate.all.to_a.filter { |update| update.gem_version > gem_version && (update.urgent? || update.patch_type?) }
  end

  def gem_version
    @gem_version ||= Gem::Version.new(Mastodon::Version.to_s.split('+')[0])
  end
end
