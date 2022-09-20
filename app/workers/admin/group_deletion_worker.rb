# frozen_string_literal: true

class Admin::GroupDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(group_id)
    DeleteGroupService.new.call(Group.find(group_id), keep_record: true)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
