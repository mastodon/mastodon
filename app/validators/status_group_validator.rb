# frozen_string_literal: true

class StatusGroupValidator < ActiveModel::Validator
  def validate(status)
    status.errors.add(:base, I18n.t('statuses.group_errors.invalid_reply')) if status.in_reply_to_id && status.thread&.group_id != status.group_id
    return if status.group_id.nil? && !status.group_visibility?

    if status.group_id.nil? || status.group.nil?
      status.errors.add(:base, I18n.t('statuses.group_errors.invalid_group_id'))
      return
    end

    status.errors.add(:base, I18n.t('statuses.group_errors.invalid_visibility')) unless status.group_visibility?

    return unless status.local? || status.group.local? # Accept a remote group's decision on remote posts

    status.errors.add(:base, I18n.t('statuses.group_errors.invalid_membership')) unless status.group.members.where(id: status.account_id).exists?
  end
end
