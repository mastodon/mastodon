# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker
  include DatabaseHelper

  def perform(status_id, id, type = 'home', options = {})
    with_primary do
      @type      = type.to_sym
      @status    = Status.find(status_id)
      @options   = options.symbolize_keys

      case @type
      when :home, :tags
        @follower = Account.find(id)
      when :list
        @list     = List.find(id)
        @follower = @list.account
      end
    end

    with_read_replica do
      check_and_insert
    end
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def check_and_insert
    filter_result = feed_filter

    if filter_result
      perform_unpush if update?
    else
      perform_push
    end

    perform_notify if notify?(filter_result)
  end

  def feed_filter
    case @type
    when :home
      FeedManager.instance.filter(:home, @status, @follower)
    when :tags
      FeedManager.instance.filter(:tags, @status, @follower)
    when :list
      FeedManager.instance.filter(:list, @status, @list)
    end
  end

  def notify?(filter_result)
    return false if @type != :home || @status.reblog? || (@status.reply? && @status.in_reply_to_account_id != @status.account_id) ||
                    update? || filter_result == :filter

    Follow.find_by(account: @follower, target_account: @status.account)&.notify?
  end

  def perform_push
    case @type
    when :home, :tags
      FeedManager.instance.push_to_home(@follower, @status, update: update?)
    when :list
      FeedManager.instance.push_to_list(@list, @status, update: update?)
    end
  end

  def perform_unpush
    case @type
    when :home, :tags
      FeedManager.instance.unpush_from_home(@follower, @status, update: true)
    when :list
      FeedManager.instance.unpush_from_list(@list, @status, update: true)
    end
  end

  def perform_notify
    LocalNotificationWorker.perform_async(@follower.id, @status.id, 'Status', 'status')
  end

  def update?
    @options[:update]
  end
end
