class RejectFollowingBlockedUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    blocked_follows = Follow.find_by_sql(<<-SQL.squish)
      select f.* from follows f
      inner join blocks b on
        f.account_id = b.target_account_id and
        f.target_account_id = b.account_id
    SQL

    domain_blocked_follows = Follow.find_by_sql(<<-SQL.squish)
      select f.* from follows f
      inner join accounts following on f.account_id = following.id
      inner join account_domain_blocks b on
        lower(b.domain) = lower(following.domain) and
        f.target_account_id = b.account_id
    SQL

    follows = (blocked_follows + domain_blocked_follows).uniq
    say "Destroying #{follows.size} blocked follow relationships..."

    follows.each do |follow|
      blocked_account = follow.account
      followed_account = follow.target_account

      next follow.destroy! if blocked_account.local?

      reject_follow_json = Oj.dump(ActivityPub::LinkedDataSignature.new(ActiveModelSerializers::SerializableResource.new(follow, serializer: ActivityPub::RejectFollowSerializer, adapter: ActivityPub::Adapter).as_json).sign!(followed_account))

      ActivityPub::DeliveryWorker.perform_async(reject_follow_json, followed_account, blocked_account.inbox_url)

      follow.destroy!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
