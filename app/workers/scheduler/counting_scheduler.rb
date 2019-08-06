# frozen_string_literal: true

class Scheduler::CountingScheduler
  include Sidekiq::Worker

  sidekiq_options unique: :until_executed, retry: 0

  def perform
    recount_tag_scores!
    recount_account_counters!
  end

  private

  def recount_tag_scores!
    Tag.active.find_each do |tag|
      tag.score = Redis.current.pfcount(*(0..7).map { |i| "activity:tags:#{tag.id}:#{i.days.ago.beginning_of_day.to_i}:accounts" })
      tag.save if tag.changed?
    end
  end

  def recount_account_counters!
    Account.joins(:user).merge(User.active).includes(:account_stat).find_each do |account|
      account.account_stat.following_count = account.active_relationships.count
      account.account_stat.followers_count = account.passive_relationships.count
      account.account_stat.statuses_count  = account.statuses.where.not(visibility: :direct).count

      account.account_stat.save if account.account_stat.changed?
    end
  end
end
