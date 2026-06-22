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
      .where("regexp_substr(collections.uri, '/ap/users/\\d+/') != regexp_substr(accounts.collections_url, '/ap/users/\\d+/')")
    affected_collections = affected_collections.where(id: last_known_good...) if last_known_good

    successful = affected_collections.map do |collection|
      json = fetch_resource(collection.uri, true)
      next false if json.nil? || !json.is_a?(Hash) || !json.key?('attributedTo')

      account = Account.find_by(uri: json['attributedTo'])
      account ||= ActivityPub::FetchRemoteAccountService.new.call(json['attributedTo'])
      next false if account.nil?

      collection.update(account:)
      true
    end

    redis.set('remote_collection_repair:last_known_good', max_id.to_s) if successful.all?
  end
end
