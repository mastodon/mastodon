# frozen_string_literal: true

class Form::RelayPreferencesBatch < Form::BaseBatch
  attr_reader :relay_ids

  def relay_ids=(arr)
    @relay_ids = arr.reject { |x| x.blank? || x == '0' }
  end

  def save
    # Opt-out of previously opted-in relays
    RelayPreference.includes(:relay).where(account: current_account, enabled: true).where.not(relay_id: relay_ids).find_each do |preference|
      send_block_activity(preference, preference.relay)
      preference.update!(enabled: false)
    end

    # Opt-in to previously opted-out relays
    RelayPreference.includes(:relay).where(account: current_account, enabled: false).where(relay_id: relay_ids).find_each do |preference|
      send_unblock_activity(preference, preference.relay)
      preference.update!(enabled: true)
    end

    # Opt-in to the rest
    RelayPreference.upsert_all(relay_ids.map { |relay_id| { account_id: current_account.id, relay_id: relay_id, enabled: true } }, unique_by: %w(account_id relay_id))
  end

  private

  def send_block_activity(preference, relay)
    BlockService.new.call(preference.account, relay.account)
  end

  def send_unblock_activity(preference, relay)
    UnblockService.new.call(preference.account, relay.account)
  end
end
