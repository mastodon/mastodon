class RemoveFauxRemoteAccountDuplicates < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    local_domain = Rails.configuration.x.local_domain

    # Just a safety measure to ensure that under no circumstance
    # we will query `domain IS NULL` because that would return
    # actually local accounts, the originals
    return if local_domain.nil?

    Account.where(domain: local_domain).in_batches.destroy_all
  end

  def down; end
end
