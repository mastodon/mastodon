# frozen_string_literal: true

class Form::GroupBatch
  include ActiveModel::Model
  include Authorization
  include AccountableConcern
  include Payloadable

  attr_accessor :group_ids, :action, :current_account,
                :select_all_matching, :query

  def save
    case action
    when 'suspend'
      suspend!
    end
  end

  private

  def groups
    if select_all_matching?
      query
    else
      Group.where(id: group_ids)
    end
  end

  def suspend!
    groups.find_each do |group|
      suspend_group(group)
    end
  end

  def suspend_group(group)
    authorize(group, :suspend?)
    log_action(:suspend, group)
    group.suspend!(origin: :local)
    Admin::GroupSuspensionWorker.perform_async(group.id)
  end

  def select_all_matching?
    select_all_matching == '1'
  end
end
