# frozen_string_literal: true

class MergeWorker
  include Sidekiq::Worker
  include Redisable
  include DatabaseHelper

  def perform(from_account_id, into_id, type = 'home')
    with_primary do
      @from_account = Account.find(from_account_id)
    end

    case type
    when 'home'
      merge_into_home!(into_id)
    when 'list'
      merge_into_list!(into_id)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def merge_into_home!(into_account_id)
    with_primary do
      @into_account = Account.find(into_account_id)
    end

    with_read_replica do
      FeedManager.instance.merge_into_home(@from_account, @into_account)
    end
  ensure
    HomeFeed.new(@into_account).regeneration_finished!
  end

  def merge_into_list!(into_list_id)
    with_primary do
      @into_list = List.find(into_list_id)
    end

    with_read_replica do
      FeedManager.instance.merge_into_list(@from_account, @into_list)
    end
  end
end
