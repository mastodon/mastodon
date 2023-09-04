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
    @software_updates ||= SoftwareUpdate.pending_to_a.filter { |update| update.urgent? || update.patch_type? }
  end
end
