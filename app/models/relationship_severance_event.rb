# frozen_string_literal: true

# == Schema Information
#
# Table name: relationship_severance_events
#
#  id          :bigint(8)        not null, primary key
#  type        :integer          not null
#  target_name :string           not null
#  purged      :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class RelationshipSeveranceEvent < ApplicationRecord
  self.inheritance_column = nil

  has_many :severed_relationships, inverse_of: :relationship_severance_event, dependent: :delete_all

  enum :type, {
    domain_block: 0,
    user_domain_block: 1,
    account_suspension: 2,
  }

  scope :about_local_account, ->(account) { where(id: SeveredRelationship.about_local_account(account).select(:relationship_severance_event_id)) }

  def import_from_active_follows!(follows)
    import_from_follows!(follows, true)
  end

  def import_from_passive_follows!(follows)
    import_from_follows!(follows, false)
  end

  def affected_local_accounts
    Account.where(id: severed_relationships.select(:local_account_id))
  end

  private

  def import_from_follows!(follows, active)
    SeveredRelationship.insert_all(
      follows.pluck(:account_id, :target_account_id, :show_reblogs, :notify, :languages).map do |account_id, target_account_id, show_reblogs, notify, languages|
        {
          local_account_id: active ? account_id : target_account_id,
          remote_account_id: active ? target_account_id : account_id,
          show_reblogs: show_reblogs,
          notify: notify,
          languages: languages,
          relationship_severance_event_id: id,
          direction: active ? :active : :passive,
        }
      end
    )
  end
end
