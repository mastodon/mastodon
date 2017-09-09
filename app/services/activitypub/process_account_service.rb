# frozen_string_literal: true

class ActivityPub::ProcessAccountService < BaseService
  include JsonLdHelper

  # Should be called with confirmed valid JSON
  # and WebFinger-resolved username and domain
  def call(username, domain, json)
    return unless json['inbox'].present?

    @json     = json
    @uri      = @json['id']
    @username = username
    @domain   = domain
    @account  = Account.find_by(uri: @uri)

    create_account  if @account.nil?
    upgrade_account if @account.ostatus?
    update_account

    @account
  rescue Oj::ParseError
    nil
  end

  private

  def create_account
    @account = Account.new
    @account.protocol    = :activitypub
    @account.username    = @username
    @account.domain      = @domain
    @account.uri         = @uri
    @account.suspended   = true if auto_suspend?
    @account.silenced    = true if auto_silence?
    @account.private_key = nil
    @account.save!
  end

  def update_account
    @account.last_webfingered_at = Time.now.utc
    @account.protocol            = :activitypub
    @account.inbox_url           = @json['inbox'] || ''
    @account.outbox_url          = @json['outbox'] || ''
    @account.shared_inbox_url    = @json['sharedInbox'] || ''
    @account.followers_url       = @json['followers'] || ''
    @account.url                 = @json['url'] || @uri
    @account.display_name        = @json['name'] || ''
    @account.note                = @json['summary'] || ''
    @account.avatar_remote_url   = image_url('icon')
    @account.header_remote_url   = image_url('image')
    @account.public_key          = public_key || ''
    @account.locked              = @json['manuallyApprovesFollowers'] || false
    @account.save!
  end

  def upgrade_account
    ActivityPub::PostUpgradeWorker.perform_async(@account.domain)
  end

  def image_url(key)
    value = first_of_value(@json[key])

    return if value.nil?
    return @json[key]['url'] if @json[key].is_a?(Hash)

    image = fetch_resource(value)
    image['url'] if image
  end

  def public_key
    value = first_of_value(@json['publicKey'])

    return if value.nil?
    return value['publicKeyPem'] if value.is_a?(Hash)

    key = fetch_resource(value)
    key['publicKeyPem'] if key
  end

  def auto_suspend?
    domain_block && domain_block.suspend?
  end

  def auto_silence?
    domain_block && domain_block.silence?
  end

  def domain_block
    return @domain_block if defined?(@domain_block)
    @domain_block = DomainBlock.find_by(domain: @domain)
  end
end
