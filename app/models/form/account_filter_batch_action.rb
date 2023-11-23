# frozen_string_literal: true

class Form::AccountFilterBatchAction
  include ActiveModel::Model
  include AccountableConcern
  include Authorization

  attr_accessor :current_account, :type,
                :account_filter_ids, :filter_id

  def save!
    process_action!
  end

  private

  def account_filters
    filter = current_account.custom_filters.find(filter_id)
    filter.accounts.where(id: account_filter_ids)
  end

  def process_action!
    return if account_filter_ids.empty?

    case type
    when 'remove'
      handle_remove!
    end
  end

  def handle_remove!
    account_filters.destroy_all
  end
end
