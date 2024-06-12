# frozen_string_literal: true

class ActivityPub::Activity::Update < ActivityPub::Activity
  def perform
    @account.schedule_refresh_if_stale!

    dereference_object!

    if equals_or_includes_any?(@object['type'], %w(Application Group Organization Person Service))
      update_account
    elsif equals_or_includes_any?(@object['type'], %w(Note Question))
      update_status
    elsif converted_object_type?
      Status.find_by(uri: object_uri, account_id: @account.id)
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
    webfinger = Webfinger.new("acct:#{@object['preferredUsername']}@#{@account.domain}").perform
    confirmed_username, confirmed_domain = webfinger.subject.delete_prefix('acct:').split('@')
    confirmed_username == @object['preferredUsername'] && confirmed_domain == @account.domain
  end
end
