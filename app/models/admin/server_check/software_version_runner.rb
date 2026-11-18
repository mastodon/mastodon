# frozen_string_literal: true

class Admin::ServerCheck::SoftwareVersionRunner
  include Admin::ServerCheck::Runner

  def authorized?(user)
    user.can?(:view_devops)
  end

  def run
    severity = :warning

    return ok(severity:) unless SoftwareUpdate.check_enabled?

    software_updates = SoftwareUpdate.pending_to_a
    return ok(severity:) if software_updates.empty?

    data = { reason: :regular }
    if software_updates.any?(&:urgent?)
      data[:reason] = :urgent
      severity = :critical
    elsif software_updates.any?(&:patch_type?)
      data[:reason] = :patch
    end

    pending(data:, severity:)
  end
end
