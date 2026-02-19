# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  # Updates to unknown objects older than that are ignored
  OBJECT_AGE_THRESHOLD = 1.day

  def perform
    @account.schedule_refresh_if_stale!

    dereference_object!

    if equals_or_includes_any?(@object['type'], %w(Application Group Organization Person Service))
      update_account
    elsif supported_object_type? || converted_object_type?
      update_status
    end
  end

  private

  def update_account
    return reject_payload! if @account.uri != object_uri

    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object, signed_with_known_key: true, request_id: @options[:request_id])
  end

  def update_status
    return reject_payload! if non_matching_uri_hosts?(@account.uri, object_uri)

    @status = Status.find_by(uri: object_uri, account_id: @account.id)

    # Ignore updates for old unknown objects, since those are updates we are not interested in
    # Also ignore unknown objects from suspended users for the same reasons
    return if @status.nil? && (@account.suspended? || object_too_old?)

    # We may be getting `Create` and `Update` out of order
    @status ||= ActivityPub::Activity::Create.new(@json, @account, **@options).perform

    return if @status.nil?

    ActivityPub::ProcessStatusUpdateService.new.call(@status, @json, @object, request_id: @options[:request_id])
  end

  def object_too_old?
    @object['published'].present? && @object['published'].to_datetime < OBJECT_AGE_THRESHOLD.ago
  rescue Date::Error
    false
  end
end
