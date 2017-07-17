# frozen_string_literal: true

class ActivityPub::ProcessCollectionService < BaseService
  include JsonLdHelper

  def call(body, account)
    @account = account
    @json    = Oj.load(body, mode: :strict)

    return if @account.suspended? || !supported_context?

    case @json['type']
    when 'Collection', 'CollectionPage'
      process_items @json['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      process_items @json['orderedItems']
    else
      process_items [@json]
    end
  end

  private

  def process_items(items)
    items.reverse_each.map { |item| ProcessItem.new.call(item, @account) }.compact
  end

  def supported_context?
    super(@json)
  end

  class ProcessItem
    include JsonLdHelper

    def call(json, account)
      @account = account
      @json    = json
      @object  = @json['object']

      case @json['type']
      when 'Create'
        create_original_status
      when 'Announce'
        create_shared_status
      when 'Delete'
        delete_status
      when 'Follow'
        register_follow
      when 'Like'
        register_favourite
      when 'Block'
        register_block
      when 'Update'
        process_update
      when 'Undo'
        process_undo
      end
    end

    private

    def process_update
      case @object['type']
      when 'Actor'
        update_profile
      end
    end

    def process_undo
      case @object['type']
      when 'Follow'
        register_unfollow
      when 'Like'
        register_unfavourite
      when 'Block'
        register_unblock
      end
    end

    def create_original_status
      return if delete_arrived_first? || unsupported_object_type?

      status = Status.find_by(uri: object_uri)

      return status unless status.nil?

      ApplicationRecord.transaction do
        status = Status.create!(status_params)

        process_tags(status)
        process_attachments(status)
      end

      resolve_thread(status)
      distribute(status)

      status
    end

    def create_shared_status
      original_status = status_from_uri(object_uri)
      original_status = ActivityPub::FetchRemoteStatusService.new.call(object_uri) if status.nil?

      return if original_status.nil?

      status = Status.create!(account: @account, reblog: original_status)
      distribute(status)
      status
    end

    def delete_status
      status = Status.find_by(uri: object_uri, account: @account)

      if status.nil?
        redis.setex("delete_upon_arrival:#{@account.id}:#{object_uri}", 6.hours.seconds, object_uri)
      else
        RemoveStatusService.new.call(status)
      end
    end

    def status_params
      {
        uri: @object['id'],
        url: @object['url'],
        account: @account,
        text: @object['content'],
        spoiler_text: @object['summary'],
        created_at: @object['published'],
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
        end
      end
    end

    def process_hashtag(tag, status)
      hashtag = tag['name'].gsub(/\A#/, '').mb_chars.downcase
      hashtag = Tag.where(name: hashtag).first_or_initialize(name: hashtag)

      status.tags << hashtag
    end

    def process_mention(tag, status)
      account = account_from_uri(tag['href'])
      account = ActivityPub::FetchRemoteAccountService.new.call(tag['href']) if account.nil?
      return if account.nil?
      account.mentions.create(status: status)
    end

    def process_attachments(status)
      return unless @object['attachment'].is_a?(Array)

      @object['attachment'].each do |attachment|
        next if unsupported_media_type?(attachment['mediaType'])

        href             = Addressable::URI.parse(attachment['url']).normalize.to_s
        media_attachment = MediaAttachment.create(status: status, account: status.account, remote_url: href)

        next if skip_download?

        media_attachment.file_remote_url = href
        media_attachment.save
      end
    end

    def resolve_thread(status)
      return unless status.reply? && status.thread.nil?
      ActivityPub::ThreadResolveWorker.perform_async(status.id, @object['inReplyTo'])
    end

    def distribute(status)
      notify_about_reblog(status) if reblog_of_local_account?(status)
      notify_about_mentions(status)
      crawl_links(status)
      distribute_to_followers(status)
    end

    def reblog_of_local_account?(status)
      status.reblog? && status.reblog.account.local?
    end

    def notify_about_reblog(status)
      NotifyService.new.call(status.reblog.account, status)
    end

    def notify_about_mentions(status)
      status.mentions.includes(:account).each do |mention|
        next unless mention.account.local? && audience_includes?(mention.account)
        NotifyService.new.call(mention.account, mention)
      end
    end

    def crawl_links(status)
      return if status.spoiler_text?
      LinkCrawlWorker.perform_async(status.id)
    end

    def distribute_to_followers(status)
      DistributionWorker.perform_async(status.id)
    end

    def object_uri
      @object_uri ||= @object.is_a?(String) ? @object : @object['id']
    end

    def conversation_from_uri(uri)
      return nil if uri.nil?
      return Conversation.find_by(id: TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')) if TagManager.instance.local_id?(uri)
      Conversation.find_by(uri: uri) || Conversation.create!(uri: uri)
    end

    def visibility_from_audience
      if equals_or_includes?(@object['to'], ActivityPub::TagManager::COLLECTIONS[:public])
        :public
      elsif equals_or_includes?(@object['cc'], ActivityPub::TagManager::COLLECTIONS[:public])
        :unlisted
      elsif equals_or_includes?(@object['to'], @account.followers_uri)
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
      return if @object['inReplyTo'].blank?
      @replied_to_status ||= status_from_uri(@object['inReplyTo'])
    end

    def status_from_uri(uri)
      ActivityPub::TagManager.instance.uri_to_resource(uri, Status)
    end

    def account_from_uri(uri)
      ActivityPub::TagManager.instance.uri_to_resource(uri, Account)
    end

    def redis
      Redis.current
    end

    def delete_arrived_first?
      redis.exists("delete_upon_arrival:#{@account.id}:#{object_uri}")
    end

    def unsupported_object_type?
      @object.is_a?(String) || !%w(Article Note).include?(@object['type'])
    end

    def skip_download?
      return @skip_download if defined?(@skip_download)
      @skip_download ||= DomainBlock.find_by(domain: @account.domain)&.reject_media?
    end

    def register_follow
      raise NotImplementedError
    end

    def register_favourite
      raise NotImplementedError
    end

    def register_block
      raise NotImplementedError
    end

    def update_profile
      raise NotImplementedError
    end

    def register_unfollow
      raise NotImplementedError
    end

    def register_unfavourite
      raise NotImplementedError
    end

    def register_unblock
      raise NotImplementedError
    end
  end
end
