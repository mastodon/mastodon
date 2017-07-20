# frozen_string_literal: true

class OStatus::Activity::Creation < OStatus::Activity::Base
  def perform
    if redis.exists("delete_upon_arrival:#{@account.id}:#{id}")
      Rails.logger.debug "Delete for status #{id} was queued, ignoring"
      return [nil, false]
    end

    return [nil, false] if @account.suspended?

    Rails.logger.debug "Creating remote status #{id}"

    # Return early if status already exists in db
    status = find_status(id)

    return [status, false] unless status.nil?

    status = Status.create!(
      uri: id,
      url: url,
      account: @account,
      reblog: reblog,
      text: content,
      spoiler_text: content_warning,
      created_at: published,
      reply: thread?,
      language: content_language,
      visibility: visibility_scope,
      conversation: find_or_create_conversation,
      thread: thread? ? find_status(thread.first) : nil
    )

    save_mentions(status)
    save_hashtags(status)
    save_media(status)

    if thread? && status.thread.nil?
      Rails.logger.debug "Trying to attach #{status.id} (#{id}) to #{thread.first}"
      ThreadResolveWorker.perform_async(status.id, thread.second)
    end

    Rails.logger.debug "Queuing remote status #{status.id} (#{id}) for distribution"

    LinkCrawlWorker.perform_async(status.id) unless status.spoiler_text?
    DistributionWorker.perform_async(status.id)

    [status, true]
  end

  def content
    @xml.at_xpath('./xmlns:content', xmlns: TagManager::XMLNS).content
  end

  def content_language
    @xml.at_xpath('./xmlns:content', xmlns: TagManager::XMLNS)['xml:lang']&.presence || 'en'
  end

  def content_warning
    @xml.at_xpath('./xmlns:summary', xmlns: TagManager::XMLNS)&.content || ''
  end

  def visibility_scope
    @xml.at_xpath('./mastodon:scope', mastodon: TagManager::MTDN_XMLNS)&.content&.to_sym || :public
  end

  def published
    @xml.at_xpath('./xmlns:published', xmlns: TagManager::XMLNS).content
  end

  def thread?
    !@xml.at_xpath('./thr:in-reply-to', thr: TagManager::THR_XMLNS).nil?
  end

  def thread
    thr = @xml.at_xpath('./thr:in-reply-to', thr: TagManager::THR_XMLNS)
    [thr['ref'], thr['href']]
  end

  private

  def find_or_create_conversation
    uri = @xml.at_xpath('./ostatus:conversation', ostatus: TagManager::OS_XMLNS)&.attribute('ref')&.content
    return if uri.nil?

    if TagManager.instance.local_id?(uri)
      local_id = TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')
      return Conversation.find_by(id: local_id)
    end

    Conversation.find_by(uri: uri) || Conversation.create!(uri: uri)
  end

  def save_mentions(parent)
    processed_account_ids = []

    @xml.xpath('./xmlns:link[@rel="mentioned"]', xmlns: TagManager::XMLNS).each do |link|
      next if [TagManager::TYPES[:group], TagManager::TYPES[:collection]].include? link['ostatus:object-type']

      mentioned_account = account_from_href(link['href'])

      next if mentioned_account.nil? || processed_account_ids.include?(mentioned_account.id)

      mentioned_account.mentions.where(status: parent).first_or_create(status: parent)

      # So we can skip duplicate mentions
      processed_account_ids << mentioned_account.id
    end
  end

  def save_hashtags(parent)
    tags = @xml.xpath('./xmlns:category', xmlns: TagManager::XMLNS).map { |category| category['term'] }.select(&:present?)
    ProcessHashtagsService.new.call(parent, tags)
  end

  def save_media(parent)
    do_not_download = DomainBlock.find_by(domain: parent.account.domain)&.reject_media?

    @xml.xpath('./xmlns:link[@rel="enclosure"]', xmlns: TagManager::XMLNS).each do |link|
      next unless link['href']

      media = MediaAttachment.where(status: parent, remote_url: link['href']).first_or_initialize(account: parent.account, status: parent, remote_url: link['href'])
      parsed_url = Addressable::URI.parse(link['href']).normalize

      next if !%w(http https).include?(parsed_url.scheme) || parsed_url.host.empty?

      media.save

      next if do_not_download

      begin
        media.file_remote_url = link['href']
        media.save!
      rescue ActiveRecord::RecordInvalid
        next
      end
    end
  end

  def account_from_href(href)
    url = Addressable::URI.parse(href).normalize

    if TagManager.instance.web_domain?(url.host)
      Account.find_local(url.path.gsub('/users/', ''))
    else
      Account.where(uri: href).or(Account.where(url: href)).first || FetchRemoteAccountService.new.call(href)
    end
  end
end
