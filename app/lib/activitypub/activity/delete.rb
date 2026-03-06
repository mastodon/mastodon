# frozen_string_literal: true

class ActivityPub::Activity::Delete < ActivityPub::Activity
  def perform
    if @account.uri == object_uri
      delete_person
    else
      delete_object
    end
  end

  private

  def delete_person
    with_redis_lock("delete_in_progress:#{@account.id}", autorelease: 2.hours, raise_on_failure: false) do
      DeleteAccountService.new.call(@account, reserve_username: false, skip_activitypub: true)
    end
  end

  def delete_object
    return if object_uri.nil?

    with_redis_lock("delete_status_in_progress:#{object_uri}", raise_on_failure: false) do
      unless non_matching_uri_hosts?(@account.uri, object_uri)
        # This lock ensures a concurrent `ActivityPub::Activity::Create` either
        # does not create a status at all, or has finished saving it to the
        # database before we try to load it.
        # Without the lock, `delete_later!` could be called after `delete_arrived_first?`
        # and `Status.find` before `Status.create!`
        with_redis_lock("create:#{object_uri}") { delete_later!(object_uri, delete_published_at&.to_i) }

        # TODO: will only work if we have a unique index
        Tombstone.upsert(
          {
            account_id: @account.id,
            uri: object_uri,
            created_at: delete_published_at || Time.now.utc,
          },
          on_duplicate: Arel.sql('created_at = GREATEST(tombstones.created_at, EXCLUDED.created_at)'),
          unique_by: %i(account_id uri)
        )
      end

      case @object['type']
      when 'QuoteAuthorization'
        revoke_quote
      when 'Note', 'Question'
        delete_status
      else
        delete_status || revoke_quote
      end
    end
  end

  def delete_status
    @status   = Status.find_by(uri: object_uri, account: @account)
    @status ||= Status.find_by(uri: @object['atomUri'], account: @account) if @object.is_a?(Hash) && @object['atomUri'].present?

    return if @status.nil?

    forwarder.forward! if forwarder.forwardable?
    RemoveStatusService.new.call(@status, redraft: false)

    true
  end

  def revoke_quote
    @quote = Quote.find_by(approval_uri: object_uri, quoted_account: @account, state: [:pending, :accepted])
    return if @quote.nil?

    ActivityPub::Forwarder.new(@account, @json, @quote.status).forward! if @quote.status.present?

    @quote.reject!

    DistributionWorker.perform_async(@quote.status_id, { 'update' => true }) if @quote.status.present?
  end

  def forwarder
    @forwarder ||= ActivityPub::Forwarder.new(@account, @json, @status)
  end

  def delete_published_at
    # TODO: maybe do some sanity check on the date?
    @json['published']&.to_datetime
  rescue ArgumentError
    nil
  end
end
