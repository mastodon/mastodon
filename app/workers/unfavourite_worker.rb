# frozen_string_literal: true

class UnfavouriteWorker < ApplicationWorker
  def perform(account_id, status_id)
    UnfavouriteService.new.call(Account.find(account_id), Status.find(status_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
