# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    if @account.uri == object_uri
      delete_person
    else
      delete_note
    end
  end

  private

  def delete_person
    lock_or_return("delete_in_progress:#{@account.id}") do
      DeleteAccountService.new.call(@account, reserve_username: false, skip_activitypub: true)
    end
  end

  def delete_note
    return if object_uri.nil?

    lock_or_return("delete_status_in_progress:#{object_uri}", 5.minutes.seconds) do
      unless invalid_origin?(object_uri)
        # This lock ensures a concurrent `ActivityPub::Activity::Create` either
        # does not create a status at all, or has finished saving it to the
        # database before we try to load it.
        # Without the lock, `delete_later!` could be called after `delete_arrived_first?`
        # and `Status.find` before `Status.create!`
        lock_or_fail("create:#{object_uri}") { delete_later!(object_uri) }

        Tombstone.find_or_create_by(uri: object_uri, account: @account)
      end

      @status   = Status.find_by(uri: object_uri, account: @account)
      @status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

      return if @status.nil?

      forwarder.forward! if forwarder.forwardable?
      delete_now!
    end
  end

  def forwarder
    @forwarder ||= ActivityPub::Forwarder.new(@account, @json, @status)
  end

  def delete_now!
    RemoveStatusService.new.call(@status, redraft: false)
  end
end
