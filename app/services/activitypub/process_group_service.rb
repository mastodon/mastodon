# frozen_string_literal: true

class ActivityPub::ProcessGroupService < BaseService
  include JsonLdHelper
  include DomainControlHelper
  include Redisable
  include Lockable

  # Should be called with confirmed valid JSON
  def call(json, options = {})
    @uri = json['id']
    domain = Addressable::URI.parse(@uri).normalized_host
    return if json['inbox'].blank? || unsupported_uri_scheme?(json['id']) || domain_not_allowed?(domain)

    @options     = options
    @json        = json
    @domain      = domain
    @collections = {}

    with_lock("process_group:#{@uri}") do
      @group = Group.remote.find_by(uri: @uri)
      @suspension_changed = false

      # TODO: assert compatibility; what happens if compatibility drops? (e.g. public -> private switch)
      create_group! if @group.nil?
      update_group!
      process_tags!
    end

    after_suspension_change! if suspension_changed?

    unless @options[:only_key] || @group.suspended?
      # TODO: crawl collections? members and outbox
    end

    @group
  rescue Oj::ParseError
    nil
  end

  private

  def create_group!
    @group = Group.new
    @group.domain            = @domain
    @group.private_key       = nil
    @group.suspended_at      = domain_block.created_at if auto_suspend?
    @group.suspension_origin = :local if auto_suspend?

    # TODO: somehow convert follows to memberships if an account exists? idk
  end

  def update_group!
    # TODO: @group.last_webfingered_at = Time.now.utc unless @options[:only_key]

    set_suspension!
    set_immediate_protocol_attributes!
    set_fetchable_key! unless @group.suspended? && @group.suspension_origin_local?
    set_immediate_attributes! unless @group.suspended?
    set_fetchable_attributes! unless @options[:only_key] || @group.suspended?

    @group.save_with_optional_media!
  end

  def set_immediate_protocol_attributes!
    @group.inbox_url        = @json['inbox'] || ''
    @group.outbox_url       = @json['outbox'] || ''
    @group.wall_url         = @json['wall']
    @group.members_url      = @json['members'] || ''
    @group.shared_inbox_url = (@json['endpoints'].is_a?(Hash) ? @json['endpoints']['sharedInbox'] : @json['sharedInbox']) || ''
    @group.url              = url || @uri
    @group.uri              = @uri
    @group.created_at       = @json['published'] if @json['published'].present?
  end

  def set_immediate_attributes!
    @group.display_name = @json['name'] || ''
    @group.note         = @json['summary'] || ''
    @group.locked       = @json['manuallyApprovesMembers'] || false
    @group.discoverable = @json['discoverable'] || false
  end

  def set_fetchable_key!
    @group.public_key = public_key || ''
  end

  def set_fetchable_attributes!
    begin
      @group.avatar_remote_url = image_url('icon') || '' unless skip_download?
      @group.avatar = nil if @group.avatar_remote_url.blank?
    rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
      RedownloadAvatarWorker.perform_in(rand(30..600).seconds, @group.id, 'Group')
    end

    begin
      @group.header_remote_url = image_url('image') || '' unless skip_download?
      @group.header = nil if @group.header_remote_url.blank?
    rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
      RedownloadHeaderWorker.perform_in(rand(30..600).seconds, @group.id, 'Group')
    end

    @group.hide_members = members_private?

    attributed_to_uris = as_array(@json['attributedTo']).filter_map do |item|
      uri = value_or_id(item)
      uri unless ActivityPub::TagManager.instance.local_uri?(uri)
    end

    ActivityPub::UpdateRemoteGroupAdminsWorker.perform_async(@group.id, attributed_to_uris) unless attributed_to_uris.empty?
  end

  def set_suspension!
    return if @group.suspended? && @group.suspension_origin_local?

    if @group.suspended? && !@json['suspended']
      @group.unsuspend!
      @suspension_changed = true
    elsif !@group.suspended? && @json['suspended']
      @group.suspend!(origin: :remote)
      @suspension_changed = true
    end
  end

  def after_suspension_change!
    if @group.suspended?
      Admin::GroupSuspensionWorker.perform_async(@group.id)
    else
      Admin::GroupUnsuspensionWorker.perform_async(@group.id)
    end
  end

  def image_url(key)
    value = first_of_value(@json[key])

    return if value.nil?
    return value['url'] if value.is_a?(Hash)

    image = fetch_resource_without_id_validation(value)
    image['url'] if image
  end

  def public_key
    value = first_of_value(@json['publicKey'])

    return if value.nil?
    return value['publicKeyPem'] if value.is_a?(Hash)

    key = fetch_resource_without_id_validation(value)
    key['publicKeyPem'] if key
  end

  def url
    return if @json['url'].blank?

    url_candidate = url_to_href(@json['url'], 'text/html')

    if unsupported_uri_scheme?(url_candidate) || mismatching_origin?(url_candidate)
      nil
    else
      url_candidate
    end
  end

  def mismatching_origin?(url)
    needle   = Addressable::URI.parse(url).host
    haystack = Addressable::URI.parse(@uri).host

    !haystack.casecmp(needle).zero?
  end

  def members_private?
    !collection_info('members').last
  end

  def collection_info(type)
    return [nil, nil] if @json[type].blank?
    return @collections[type] if @collections.key?(type)

    collection = fetch_resource_without_id_validation(@json[type])

    total_items = collection.is_a?(Hash) && collection['totalItems'].present? && collection['totalItems'].is_a?(Numeric) ? collection['totalItems'] : nil
    has_first_page = collection.is_a?(Hash) && collection['first'].present?
    @collections[type] = [total_items, has_first_page]
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Mastodon::LengthValidationError
    @collections[type] = [nil, nil]
  end

  def skip_download?
    @group.suspended? || domain_block&.reject_media?
  end

  def auto_suspend?
    domain_block&.suspend?
  end

  def domain_block
    return @domain_block if defined?(@domain_block)
    @domain_block = DomainBlock.rule_for(@domain)
  end

  def suspension_changed?
    @suspension_changed
  end

  def process_tags!
    return if @json['tag'].blank?

    as_array(@json['tag']).each do |tag|
      process_emoji tag if equals_or_includes?(tag['type'], 'Emoji')
    end
  end

  def process_emoji(tag)
    return if skip_download?
    return if tag['name'].blank? || tag['icon'].blank? || tag['icon']['url'].blank?

    shortcode = tag['name'].delete(':')
    image_url = tag['icon']['url']
    uri       = tag['id']
    updated   = tag['updated']
    emoji     = CustomEmoji.find_by(shortcode: shortcode, domain: @group.domain)

    return unless emoji.nil? || image_url != emoji.image_remote_url || (updated && updated >= emoji.updated_at)

    emoji ||= CustomEmoji.new(domain: @group.domain, shortcode: shortcode, uri: uri)
    emoji.image_remote_url = image_url
    emoji.save
  end
end
