# frozen_string_literal: true

class MediaAttachmentPolicy < ApplicationPolicy
  def download?
    (record.discarded? && role.can?(:manage_reports)) || show_status?
  end

  private

  def show_status?
    record.status && StatusPolicy.new(current_account, record.status).show?
  end
end
