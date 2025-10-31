# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
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

    opts = {
      signed_with_known_key: true,
      request_id: @options[:request_id],
    }

    opts[:allow_username_update] = allow_username_update? if @account.username != @object['preferredUsername']

    ActivityPub::ProcessAccountService.new.call(@account.username, @account.domain, @object, opts)
  end

  def update_status
    return reject_payload! if non_matching_uri_hosts?(@account.uri, object_uri)

    @status = Status.find_by(uri: object_uri, account_id: @account.id)

    # We may be getting `Create` and `Update` out of order
    @status ||= ActivityPub::Activity::Create.new(@json, @account, **@options).perform

    return if @status.nil?

    ActivityPub::ProcessStatusUpdateService.new.call(@status, @json, @object, request_id: @options[:request_id])
  end

  def allow_username_update?
    updated_username_unique? && updated_username_confirmed?
  end

  def updated_username_unique?
    account_proxy = @account.dup
    account_proxy.username = @object['preferredUsername']
    UniqueUsernameValidator.new.validate(account_proxy)
    account_proxy.errors.blank?
  end

  def updated_username_confirmed?
    begin
      webfinger = Webfinger.new("acct:#{@object['preferredUsername']}@#{@account.domain}").perform
    rescue Webfinger::Error
      return false
    end

    confirmed_username, confirmed_domain = webfinger.subject.delete_prefix('acct:').split('@')
    confirmed_username == @object['preferredUsername'] && confirmed_domain == @account.domain
  end
end
