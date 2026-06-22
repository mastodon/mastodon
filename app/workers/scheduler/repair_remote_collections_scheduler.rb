# frozen_string_literal: true

class Scheduler::RepairRemoteCollectionsScheduler
  include Sidekiq::Worker
  include JsonLdHelper
  include Redisable

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    max_created_at = Collection.maximum(:created_at)
    last_known_good = redis.get('remote_collection_repair:last_known_good')

    affected_collections = Collection.joins(:account).where(local: false)
      .where("regexp_substr(collections.uri, '/ap/user/\\d+/') != regexp_substr(accounts.collections_url, '/ap/user/\\d+/')")
    affected_collections = affected_collections.where(created_at: Time.zone.parse(last_known_good)..) if last_known_good

    successful = affected_collections.map do |collection|
      json = fetch_resource(collection.uri, true)
      next false if json.nil? || !json.is_a?(Hash) || !json.key?('attributedTo')

      account = Account.find_by(uri: json['attributedTo'])
      account ||= ActivityPub::FetchRemoteAccountService.new.call(json['attributedTo'])
      next false if account.nil?

      collection.update(account:)
      true
    end

    redis.set('remote_collection_repair:last_known_good', max_created_at.to_s) if successful.all?
  end
end
