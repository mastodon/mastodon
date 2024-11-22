# frozen_string_literal: true

class Form::StatusFilterBatchAction
  include ActiveModel::Model
  include AccountableConcern
  include Authorization

  attr_accessor :current_account, :type,
                :status_filter_ids, :filter_id

  def save!
    process_action!
  end

  private

  def status_filters
    filter = current_account.custom_filters.find(filter_id)
    filter.statuses.where(id: status_filter_ids)
  end

  def process_action!
    return if status_filter_ids.empty?

    case type
    when 'remove'
      handle_remove!
    end
  end

  def handle_remove!
    status_filters.destroy_all
  end
end
