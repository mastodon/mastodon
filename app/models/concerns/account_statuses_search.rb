# frozen_string_literal: true

module AccountStatusesSearch
  extend ActiveSupport::Concern

  def update_statuses_index!
    Chewy.strategy(:sidekiq) do
      StatusesIndex.import(query: Status.where(account_id: id))
    end
  end
end
