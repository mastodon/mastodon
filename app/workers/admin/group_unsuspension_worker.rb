# frozen_string_literal: true

class Admin::GroupUnsuspensionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(group_id)
    UnsuspendGroupService.new.call(Group.find(group_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
