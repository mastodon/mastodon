# frozen_string_literal: true

class ActivityPub::Activity::Create < ActivityPub::Activity
  def perform
    return if delete_arrived_first?(object_uri) || unsupported_object_type?

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @status = find_existing_status
        process_status if @status.nil?
      end
    end

    @status
  end

  private

  def process_status
    ApplicationRecord.transaction do
      @status = Status.create!(status_params)

      process_tags(@status)
      process_attachments(@status)
    end

    resolve_thread(@status)
    distribute(@status)
    forward_for_reply if @status.public_visibility? || @status.unlisted_visibility?
  end

  def find_existing_status
    status   = status_from_uri(object_uri)
    status ||= Status.find_by(uri: @object['atomUri']) if @object['atomUri'].present?
    status
  end

  def status_params
    {
      uri: @object['id'],
      url: object_url || @object['id'],
      account: @account,
      text: text_from_content || '',
      language: language_from_content,
      spoiler_text: @object['summary'] || '',
      created_at: @options[:override_timestamps] ? nil : @object['published'],
      reply: @object['inReplyTo'].present?,
      sensitive: @object['sensitive'] || false,
      visibility: visibility_from_audience,
      thread: replied_to_status,
      conversation: conversation_from_uri(@object['conversation']),
    }
  end

  def process_tags(status)
    return unless @object['tag'].is_a?(Array)

    @object['tag'].each do |tag|
      case tag['type']
      when 'Hashtag'
        process_hashtag tag, status
      when 'Mention'
        process_mention tag, status
      when 'Emoji'
        process_emoji tag, status
      end
    end
  end

  def process_hashtag(tag, status)
    return if tag['name'].blank?

    hashtag = tag['name'].gsub(/\A#/, '').mb_chars.downcase
    hashtag = Tag.where(name: hashtag).first_or_initialize(name: hashtag)

    status.tags << hashtag
  end

  def process_mention(tag, status)
    return if tag['href'].blank?

    account = account_from_uri(tag['href'])
    account = FetchRemoteAccountService.new.call(tag['href'], id: false) if account.nil?
    return if account.nil?
    account.mentions.create(status: status)
  end

  def process_emoji(tag, _status)
    return if skip_download?
    return if tag['name'].blank? || tag['icon'].blank? || tag['icon']['url'].blank?

    shortcode = tag['name'].delete(':')
    image_url = tag['icon']['url']
    uri       = tag['id']
    updated   = tag['updated']
    emoji     = CustomEmoji.find_by(shortcode: shortcode, domain: @account.domain)

    return unless emoji.nil? || emoji.updated_at >= updated

    emoji ||= CustomEmoji.new(domain: @account.domain, shortcode: shortcode, uri: uri)
    emoji.image_remote_url = image_url
    emoji.save
  end

  def process_attachments(status)
    return unless @object['attachment'].is_a?(Array)

    @object['attachment'].each do |attachment|
      next if unsupported_media_type?(attachment['mediaType']) || attachment['url'].blank?

      href             = Addressable::URI.parse(attachment['url']).normalize.to_s
      media_attachment = MediaAttachment.create(status: status, account: status.account, remote_url: href, description: attachment['name'].presence)

      next if skip_download?

      media_attachment.file_remote_url = href
      media_attachment.save
    end
  rescue Addressable::URI::InvalidURIError => e
    Rails.logger.debug e
  end

  def resolve_thread(status)
    return unless status.reply? && status.thread.nil?
    ThreadResolveWorker.perform_async(status.id, in_reply_to_uri)
  end

  def conversation_from_uri(uri)
    return nil if uri.nil?
    return Conversation.find_by(id: OStatus::TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')) if OStatus::TagManager.instance.local_id?(uri)
    Conversation.find_by(uri: uri) || Conversation.create(uri: uri)
  end

  def visibility_from_audience
    if equals_or_includes?(@object['to'], ActivityPub::TagManager::COLLECTIONS[:public])
      :public
    elsif equals_or_includes?(@object['cc'], ActivityPub::TagManager::COLLECTIONS[:public])
      :unlisted
    elsif equals_or_includes?(@object['to'], @account.followers_url)
      :private
    else
      :direct
    end
  end

  def audience_includes?(account)
    uri = ActivityPub::TagManager.instance.uri_for(account)
    equals_or_includes?(@object['to'], uri) || equals_or_includes?(@object['cc'], uri)
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

  def text_from_content
    if @object['content'].present?
      @object['content']
    elsif language_map?
      @object['contentMap'].values.first
    end
  end

  def language_from_content
    return nil unless language_map?
    @object['contentMap'].keys.first
  end

  def object_url
    return if @object['url'].blank?

    value = first_of_value(@object['url'])

    return value if value.is_a?(String)

    value['href']
  end

  def language_map?
    @object['contentMap'].is_a?(Hash) && !@object['contentMap'].empty?
  end

  def unsupported_object_type?
    @object.is_a?(String) || !%w(Article Note).include?(@object['type'])
  end

  def unsupported_media_type?(mime_type)
    mime_type.present? && !(MediaAttachment::IMAGE_MIME_TYPES + MediaAttachment::VIDEO_MIME_TYPES).include?(mime_type)
  end

  def skip_download?
    return @skip_download if defined?(@skip_download)
    @skip_download ||= DomainBlock.find_by(domain: @account.domain)&.reject_media?
  end

  def reply_to_local?
    !replied_to_status.nil? && replied_to_status.account.local?
  end

  def forward_for_reply
    return unless @json['signature'].present? && reply_to_local?
    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(@json), replied_to_status.account_id)
  end

  def lock_options
    { redis: Redis.current, key: "create:#{@object['id']}" }
  end
end
