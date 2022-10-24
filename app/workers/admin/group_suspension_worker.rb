# frozen_string_literal: true

class Admin::GroupSuspensionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(group_id)
    SuspendGroupService.new.call(Group.find(group_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
