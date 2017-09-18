# frozen_string_literal: true

class ActivityPub::ProcessAccountService < BaseService
  include JsonLdHelper

  # Should be called with confirmed valid JSON
  # and WebFinger-resolved username and domain
  def call(username, domain, json)
    return if json['inbox'].blank?

    @json        = json
    @uri         = @json['id']
    @username    = username
    @domain      = domain
    @account     = Account.find_by(uri: @uri)
    @collections = {}

    old_public_key = @account&.public_key
    create_account  if @account.nil?
    upgrade_account if @account.ostatus?
    update_account
    RefollowWorker.perform_async(@account.id) if !old_public_key.nil? && old_public_key != @account.public_key

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
    @account.shared_inbox_url    = (@json['endpoints'].is_a?(Hash) ? @json['endpoints']['sharedInbox'] : @json['sharedInbox']) || ''
    @account.followers_url       = @json['followers'] || ''
    @account.url                 = url || @uri
    @account.display_name        = @json['name'] || ''
    @account.note                = @json['summary'] || ''
    @account.avatar_remote_url   = image_url('icon')  unless skip_download?
    @account.header_remote_url   = image_url('image') unless skip_download?
    @account.public_key          = public_key || ''
    @account.locked              = @json['manuallyApprovesFollowers'] || false
    @account.statuses_count      = outbox_total_items    if outbox_total_items.present?
    @account.following_count     = following_total_items if following_total_items.present?
    @account.followers_count     = followers_total_items if followers_total_items.present?
    @account.save_with_optional_media!
  end

  def upgrade_account
    ActivityPub::PostUpgradeWorker.perform_async(@account.domain)
  end

  def image_url(key)
    value = first_of_value(@json[key])

    return if value.nil?
    return value['url'] if value.is_a?(Hash)

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

  def url
    return if @json['url'].blank?

    value = first_of_value(@json['url'])

    return value if value.is_a?(String)

    value['href']
  end

  def outbox_total_items
    collection_total_items('outbox')
  end

  def following_total_items
    collection_total_items('following')
  end

  def followers_total_items
    collection_total_items('followers')
  end

  def collection_total_items(type)
    return if @json[type].blank?
    return @collections[type] if @collections.key?(type)

    collection = fetch_resource(@json[type])

    @collections[type] = collection.is_a?(Hash) && collection['totalItems'].present? && collection['totalItems'].is_a?(Numeric) ? collection['totalItems'] : nil
  rescue HTTP::Error, OpenSSL::SSL::SSLError
    @collections[type] = nil
  end

  def skip_download?
    @account.suspended? || domain_block&.reject_media?
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
