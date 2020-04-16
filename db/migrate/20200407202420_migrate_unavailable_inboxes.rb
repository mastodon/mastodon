class MigrateUnavailableInboxes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    urls = Redis.current.smembers('unavailable_inboxes')

    hosts = urls.map do |url|
      Addressable::URI.parse(url).normalized_host
    end.compact.uniq

    UnavailableDomain.delete_all

    hosts.each do |host|
      UnavailableDomain.create(domain: host)
    end

    Redis.current.del(*(['unavailable_inboxes'] + Redis.current.keys('exhausted_deliveries:*')))
  end

  def down; end
end
