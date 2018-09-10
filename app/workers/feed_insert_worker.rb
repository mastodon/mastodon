# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker

  def perform(status_id, id, type = :home)
    @type     = type.to_sym
    @status   = Status.find(status_id)

    case @type
    when :home
      @follower = Account.find(id)
    when :list
      @list     = List.find(id)
      @follower = @list.account
    end

    check_and_insert
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def check_and_insert
    perform_push unless feed_filtered?
  end

  def feed_filtered?
    # Note: Lists are a variation of home, so the filtering rules
    # of home apply to both
    FeedManager.instance.filter?(:home, @status, @follower.id)
  end

  def perform_push
    case @type
    when :home
      FeedManager.instance.push_to_home(@follower, @status)
    when :list
      FeedManager.instance.push_to_list(@list, @status)
    end
  end
end
