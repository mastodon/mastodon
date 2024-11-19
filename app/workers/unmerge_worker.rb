# frozen_string_literal: true

class UnmergeWorker
  include Sidekiq::Worker
  include DatabaseHelper

  sidekiq_options queue: 'pull'

  def perform(from_account_id, into_id, type = 'home')
    with_primary do
      @from_account = Account.find(from_account_id)
    end

    case type
    when 'home'
      unmerge_from_home!(into_id)
    when 'list'
      unmerge_from_list!(into_id)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def unmerge_from_home!(into_account_id)
    with_primary do
      @into_account = Account.find(into_account_id)
    end

    with_read_replica do
      FeedManager.instance.unmerge_from_home(@from_account, @into_account)
    end
  end

  def unmerge_from_list!(into_list_id)
    with_primary do
      @into_list = List.find(into_list_id)
    end

    with_read_replica do
      FeedManager.instance.unmerge_from_list(@from_account, @into_list)
    end
  end
end
