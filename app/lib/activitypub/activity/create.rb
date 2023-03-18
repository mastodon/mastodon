# frozen_string_literal: true

class ActivityPub::Activity::Create < ActivityPub::Activity
  include FormattingHelper

  def perform
    dereference_object!

    case @object['type']
    when 'EncryptedMessage'
      create_encrypted_message
    else
      create_status
    end
  end

  private

  def create_encrypted_message
    return reject_payload! if invalid_origin?(object_uri) || @options[:delivered_to_account_id].blank?

    target_account = Account.find(@options[:delivered_to_account_id])
    target_device  = target_account.devices.find_by(device_id: @object.dig('to', 'deviceId'))

    return if target_device.nil?

    target_device.encrypted_messages.create!(
      from_account: @account,
      from_device_id: @object.dig('attributedTo', 'deviceId'),
      type: @object['messageType'],
      body: @object['cipherText'],
      digest: @object.dig('digest', 'digestValue'),
      message_franking: message_franking.to_token
    )
  end

  def message_franking
    MessageFranking.new(
      hmac: @object.dig('digest', 'digestValue'),
      original_franking: @object['messageFranking'],
      source_account_id: @account.id,
      target_account_id: @options[:delivered_to_account_id],
      timestamp: Time.now.utc
    )
  end

  def create_status
    return reject_payload! if unsupported_object_type? || invalid_origin?(object_uri) || tombstone_exists? || !related_to_local_activity?

    with_lock("create:#{object_uri}") do
      return if delete_arrived_first?(object_uri) || poll_vote?

      @status = find_existing_status

      if @status.nil?
        process_status
      elsif @options[:delivered_to_account_id].present?
        postprocess_audience_and_deliver
      end
    end

    @status
  end

  def audience_to
    as_array(@object['to'] || @json['to']).map { |x| value_or_id(x) }
  end

  def audience_cc
    as_array(@object['cc'] || @json['cc']).map { |x| value_or_id(x) }
  end

  def process_status
    @tags                 = []
    @mentions             = []
    @silenced_account_ids = []
    @params               = {}

    process_status_params
    process_tags
    process_audience

    ApplicationRecord.transaction do
      @status = Status.create!(@params)
      attach_tags(@status)
    end

    resolve_thread(@status)
    fetch_replies(@status)
    distribute
    forward_for_reply
  end

  def distribute
    # Spread out crawling randomly to avoid DDoSing the link
    LinkCrawlWorker.perform_in(rand(1..59).seconds, @status.id)

    # Distribute into home and list feeds and notify mentioned accounts
    ::DistributionWorker.perform_async(@status.id, { 'silenced_account_ids' => @silenced_account_ids }) if @options[:override_timestamps] || @status.within_realtime_window?
  end

  def find_existing_status
    status   = status_from_uri(object_uri)
    status ||= Status.find_by(uri: @object['atomUri']) if @object['atomUri'].present?
    status
  end

  def process_status_params
    @status_parser = ActivityPub::Parser::StatusParser.new(@json, followers_collection: @account.followers_url)

    @params = {
      uri: @status_parser.uri,
      url: @status_parser.url || @status_parser.uri,
      account: @account,
      text: converted_object_type? ? converted_text : (@status_parser.text || ''),
      language: @status_parser.language,
      spoiler_text: converted_object_type? ? '' : (@status_parser.spoiler_text || ''),
      created_at: @status_parser.created_at,
      edited_at: @status_parser.edited_at && @status_parser.edited_at != @status_parser.created_at ? @status_parser.edited_at : nil,
      override_timestamps: @options[:override_timestamps],
      reply: @status_parser.reply,
      sensitive: @account.sensitized? || @status_parser.sensitive || false,
      visibility: @status_parser.visibility,
      thread: replied_to_status,
      conversation: conversation_from_uri(@object['conversation']),
      media_attachment_ids: process_attachments.take(9).map(&:id),
      poll: process_poll,
    }
  end

  def process_audience
    # Unlike with tags, there is no point in resolving accounts we don't already
    # know here, because silent mentions would only be used for local access control anyway
    accounts_in_audience = (audience_to + audience_cc).uniq.filter_map do |audience|
      account_from_uri(audience) unless ActivityPub::TagManager.instance.public_collection?(audience)
    end

    # If the payload was delivered to a specific inbox, the inbox owner must have
    # access to it, unless they already have access to it anyway
    if @options[:delivered_to_account_id]
      accounts_in_audience << delivered_to_account
      accounts_in_audience.uniq!
    end

    accounts_in_audience.each do |account|
      # This runs after tags are processed, and those translate into non-silent
      # mentions, which take precedence
      next if @mentions.any? { |mention| mention.account_id == account.id }

      @mentions << Mention.new(account: account, silent: true)

      # If there is at least one silent mention, then the status can be considered
      # as a limited-audience status, and not strictly a direct message, but only
      # if we considered a direct message in the first place
      @params[:visibility] = :limited if @params[:visibility] == :direct
    end

    # Accounts that are tagged but are not in the audience are not
    # supposed to be notified explicitly
    @silenced_account_ids = @mentions.map(&:account_id) - accounts_in_audience.map(&:id)
  end

  def postprocess_audience_and_deliver
    return if @status.mentions.find_by(account_id: @options[:delivered_to_account_id])

    @status.mentions.create(account: delivered_to_account, silent: true)
    @status.update(visibility: :limited) if @status.direct_visibility?

    return unless delivered_to_account.following?(@account)

    FeedInsertWorker.perform_async(@status.id, delivered_to_account.id, 'home')
  end

  def delivered_to_account
    @delivered_to_account ||= Account.find(@options[:delivered_to_account_id])
  end

  def attach_tags(status)
    @tags.each do |tag|
      status.tags << tag
      tag.update(last_status_at: status.created_at) if tag.last_status_at.nil? || (tag.last_status_at < status.created_at && tag.last_status_at < 12.hours.ago)
    end

    # If we're processing an old status, this may register tags as being used now
    # as opposed to when the status was really published, but this is probably
    # not a big deal
    Trends.tags.register(status)

    @mentions.each do |mention|
      mention.status = status
      mention.save
    end
  end

  def process_tags
    return if @object['tag'].nil?

    as_array(@object['tag']).each do |tag|
      if equals_or_includes?(tag['type'], 'Hashtag')
        process_hashtag tag
      elsif equals_or_includes?(tag['type'], 'Mention')
        process_mention tag
      elsif equals_or_includes?(tag['type'], 'Emoji')
        process_emoji tag
      end
    end
  end

  def process_hashtag(tag)
    return if tag['name'].blank?

    Tag.find_or_create_by_names(tag['name']) do |hashtag|
      @tags << hashtag unless @tags.include?(hashtag) || !hashtag.valid?
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def process_mention(tag)
    return if tag['href'].blank?

    account = account_from_uri(tag['href'])
    account = ActivityPub::FetchRemoteAccountService.new.call(tag['href'], request_id: @options[:request_id]) if account.nil?

    return if account.nil?

    @mentions << Mention.new(account: account, silent: false)
  end

  def process_emoji(tag)
    return if skip_download?

    custom_emoji_parser = ActivityPub::Parser::CustomEmojiParser.new(tag)

    return if custom_emoji_parser.shortcode.blank? || custom_emoji_parser.image_remote_url.blank?

    emoji = CustomEmoji.find_by(shortcode: custom_emoji_parser.shortcode, domain: @account.domain)

    return unless emoji.nil? || custom_emoji_parser.image_remote_url != emoji.image_remote_url || (custom_emoji_parser.updated_at && custom_emoji_parser.updated_at >= emoji.updated_at)

    begin
      emoji ||= CustomEmoji.new(domain: @account.domain, shortcode: custom_emoji_parser.shortcode, uri: custom_emoji_parser.uri)
      emoji.image_remote_url = custom_emoji_parser.image_remote_url
      emoji.save
    rescue Seahorse::Client::NetworkingError => e
      Rails.logger.warn "Error storing emoji: #{e}"
    end
  end

  def process_attachments
    return [] if @object['attachment'].nil?

    media_attachments = []

    as_array(@object['attachment']).each do |attachment|
      media_attachment_parser = ActivityPub::Parser::MediaAttachmentParser.new(attachment)

      next if media_attachment_parser.remote_url.blank? || media_attachments.size >= 9

      begin
        media_attachment = MediaAttachment.create(
          account: @account,
          remote_url: media_attachment_parser.remote_url,
          thumbnail_remote_url: media_attachment_parser.thumbnail_remote_url,
          description: media_attachment_parser.description,
          focus: media_attachment_parser.focus,
          blurhash: media_attachment_parser.blurhash
        )

        media_attachments << media_attachment

        next if unsupported_media_type?(media_attachment_parser.file_content_type) || skip_download?

        media_attachment.download_file!
        media_attachment.download_thumbnail!
        media_attachment.save
      rescue Mastodon::UnexpectedResponseError, HTTP::TimeoutError, HTTP::ConnectionError, OpenSSL::SSL::SSLError
        RedownloadMediaWorker.perform_in(rand(30..600).seconds, media_attachment.id)
      rescue Seahorse::Client::NetworkingError => e
        Rails.logger.warn "Error storing media attachment: #{e}"
      end
    end

    media_attachments
  rescue Addressable::URI::InvalidURIError => e
    Rails.logger.debug { "Invalid URL in attachment: #{e}" }
    media_attachments
  end

  def process_poll
    poll_parser = ActivityPub::Parser::PollParser.new(@object)

    return unless poll_parser.valid?

    @account.polls.new(
      multiple: poll_parser.multiple,
      expires_at: poll_parser.expires_at,
      options: poll_parser.options,
      cached_tallies: poll_parser.cached_tallies,
      voters_count: poll_parser.voters_count
    )
  end

  def poll_vote?
    return false if replied_to_status.nil? || replied_to_status.preloadable_poll.nil? || !replied_to_status.local? || !replied_to_status.preloadable_poll.options.include?(@object['name'])

    poll_vote! unless replied_to_status.preloadable_poll.expired?

    true
  end

  def poll_vote!
    poll = replied_to_status.preloadable_poll
    already_voted = true

    with_lock("vote:#{replied_to_status.poll_id}:#{@account.id}") do
      already_voted = poll.votes.where(account: @account).exists?
      poll.votes.create!(account: @account, choice: poll.options.index(@object['name']), uri: object_uri)
    end

    increment_voters_count! unless already_voted
    ActivityPub::DistributePollUpdateWorker.perform_in(3.minutes, replied_to_status.id) unless replied_to_status.preloadable_poll.hide_totals?
  end

  def resolve_thread(status)
    return unless status.reply? && status.thread.nil? && Request.valid_url?(in_reply_to_uri)

    ThreadResolveWorker.perform_async(status.id, in_reply_to_uri, { 'request_id' => @options[:request_id] })
  end

  def fetch_replies(status)
    collection = @object['replies']
    return if collection.nil?

    replies = ActivityPub::FetchRepliesService.new.call(status, collection, allow_synchronous_requests: false, request_id: @options[:request_id])
    return unless replies.nil?

    uri = value_or_id(collection)
    ActivityPub::FetchRepliesWorker.perform_async(status.id, uri, { 'request_id' => @options[:request_id] }) unless uri.nil?
  end

  def conversation_from_uri(uri)
    return nil if uri.nil?
    return Conversation.find_by(id: OStatus::TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')) if OStatus::TagManager.instance.local_id?(uri)

    begin
      Conversation.find_or_create_by!(uri: uri)
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      retry
    end
  end

  def replied_to_status
    return @replied_to_status if defined?(@replied_to_status)

    if in_reply_to_uri.blank?
      @replied_to_status = nil
    else
      @replied_to_status   = status_from_uri(in_reply_to_uri)
      @replied_to_status ||= status_from_uri(@object['inReplyToAtomUri']) if @object['inReplyToAtomUri'].present?
      @replied_to_status
    end
  end

  def in_reply_to_uri
    value_or_id(@object['inReplyTo'])
  end

  def converted_text
    linkify([@status_parser.title.presence, @status_parser.spoiler_text.presence, @status_parser.url || @status_parser.uri].compact.join("\n\n"))
  end

  def unsupported_media_type?(mime_type)
    mime_type.present? && !MediaAttachment.supported_mime_types.include?(mime_type)
  end

  def skip_download?
    return @skip_download if defined?(@skip_download)

    @skip_download ||= DomainBlock.reject_media?(@account.domain)
  end

  def reply_to_local?
    !replied_to_status.nil? && replied_to_status.account.local?
  end

  def related_to_local_activity?
    fetch? || followed_by_local_accounts? || requested_through_relay? ||
      responds_to_followed_account? || addresses_local_accounts?
  end

  def responds_to_followed_account?
    !replied_to_status.nil? && (replied_to_status.account.local? || replied_to_status.account.passive_relationships.exists?)
  end

  def addresses_local_accounts?
    return true if @options[:delivered_to_account_id]

    local_usernames = (audience_to + audience_cc).uniq.select { |uri| ActivityPub::TagManager.instance.local_uri?(uri) }.map { |uri| ActivityPub::TagManager.instance.uri_to_local_id(uri, :username) }

    return false if local_usernames.empty?

    Account.local.where(username: local_usernames).exists?
  end

  def tombstone_exists?
    Tombstone.exists?(uri: object_uri)
  end

  def forward_for_reply
    return unless @status.distributable? && @json['signature'].present? && reply_to_local?

    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(@json), replied_to_status.account_id, [@account.preferred_inbox_url])
  end

  def increment_voters_count!
    poll = replied_to_status.preloadable_poll

    unless poll.voters_count.nil?
      poll.voters_count = poll.voters_count + 1
      poll.save
    end
  rescue ActiveRecord::StaleObjectError
    poll.reload
    retry
  end
end
