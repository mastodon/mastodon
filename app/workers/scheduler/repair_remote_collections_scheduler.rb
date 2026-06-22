# frozen_string_literal: true

# TODO: Remove in the next version
class Scheduler::RepairRemoteCollectionsScheduler
  include Sidekiq::Worker
  include JsonLdHelper
  include Redisable

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    max_id = Collection.maximum(:id)
    last_known_good = redis.get('remote_collection_repair:last_known_good')

    affected_collections = Collection.joins(:account).where(local: false)
      .where("substring(collections.uri from '/ap/users/\\d+/') != substring(accounts.collections_url from '/ap/users/\\d+/')")
    affected_collections = affected_collections.where(id: last_known_good...) if last_known_good

    successful = true
    affected_collections.find_each do |collection|
      json = fetch_resource(collection.uri, true)
      if json.nil? || !json.is_a?(Hash) || !json.key?('attributedTo')
        successful = false
        next
      end

      account = Account.find_by(uri: json['attributedTo'])
      account ||= ActivityPub::FetchRemoteAccountService.new.call(json['attributedTo'])
      if account.nil?
        successful = false
        next
      end

      collection.update(account:)
    end

    redis.set('remote_collection_repair:last_known_good', max_id.to_s) if successful
  end
end
