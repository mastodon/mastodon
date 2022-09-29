# frozen_string_literal: true

class GroupDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed

  def perform(group_id, options = {})
    group = Group.find_by(id: group_id)
    return if group.nil?

    DeleteGroupService.new.call(group, keep_record: false)
  end
end

