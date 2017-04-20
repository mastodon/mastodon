# frozen_string_literal: true

class ProcessFeedService < BaseService
  def call(body, account)
    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    update_author(body, account)
    process_entries(xml, account)
  end

  private

  def update_author(body, account)
    RemoteProfileUpdateWorker.perform_async(account.id, body.force_encoding('UTF-8'), true)
  end

  def process_entries(xml, account)
    xml.xpath('//xmlns:entry', xmlns: TagManager::XMLNS).reverse_each.map { |entry| ProcessEntry.new.call(entry, account) }.compact
  end

  class ProcessEntry
    def call(xml, account)
      @account = account
      @xml     = xml

      return if skip_unsupported_type?

      case verb
      when :post, :share
        return create_status
      when :delete
        return delete_status
      end
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug "Nothing was saved for #{id} because: #{e}"
      nil
    end

    private

    def create_status
      Rails.logger.debug "Creating remote status #{id}"
      status, just_created = status_from_xml(@xml)

      return if status.nil?
      return status unless just_created

      if verb == :share
        original_status, = status_from_xml(@xml.at_xpath('.//activity:object', activity: TagManager::AS_XMLNS))
        status.reblog    = original_status

        if original_status.nil?
          status.destroy
          return nil
        elsif original_status.reblog?
          status.reblog = original_status.reblog
        end
      end

      status.save!

      notify_about_mentions!(status) unless status.reblog?
      notify_about_reblog!(status) if status.reblog? && status.reblog.account.local?
      Rails.logger.debug "Queuing remote status #{status.id} (#{id}) for distribution"
      DistributionWorker.perform_async(status.id)
      status
    end

    def notify_about_mentions!(status)
      status.mentions.includes(:account).each do |mention|
        mentioned_account = mention.account
        next unless mentioned_account.local?
        NotifyService.new.call(mentioned_account, mention)
      end
    end

    def notify_about_reblog!(status)
      NotifyService.new.call(status.reblog.account, status)
    end

    def delete_status
      Rails.logger.debug "Deleting remote status #{id}"
      status = Status.find_by(uri: id)
      RemoveStatusService.new.call(status) unless status.nil?
      nil
    end

    def skip_unsupported_type?
      !([:post, :share, :delete].include?(verb) && [:activity, :note, :comment].include?(type))
    end

    def status_from_xml(entry)
      # Return early if status already exists in db
      status = find_status(id(entry))

      return [status, false] unless status.nil?

      # If status embeds an author, find that author
      # If that author cannot be found, don't record the status (do not misattribute)
      if account?(entry)
        begin
          account = find_or_resolve_account(acct(entry))
          return [nil, false] if account.nil?
        rescue Goldfinger::Error
          return [nil, false]
        end
      else
        account = @account
      end

      return [nil, false] if account.suspended?

      status = Status.create!(
        uri: id(entry),
        url: url(entry),
        account: account,
        text: content(entry),
        spoiler_text: content_warning(entry),
        created_at: published(entry),
        reply: thread?(entry),
        language: content_language(entry),
        visibility: visibility_scope(entry)
      )

      if thread?(entry)
        Rails.logger.debug "Trying to attach #{status.id} (#{id(entry)}) to #{thread(entry).first}"
        status.thread = find_or_resolve_status(status, *thread(entry))
      end

      mentions_from_xml(status, entry)
      hashtags_from_xml(status, entry)
      media_from_xml(status, entry)

      [status, true]
    end

    def find_or_resolve_account(acct)
      FollowRemoteAccountService.new.call(acct)
    end

    def find_or_resolve_status(parent, uri, url)
      status = find_status(uri)

      ThreadResolveWorker.perform_async(parent.id, url) if status.nil?

      status
    end

    def find_status(uri)
      if TagManager.instance.local_id?(uri)
        local_id = TagManager.instance.unique_tag_to_local_id(uri, 'Status')
        return Status.find(local_id)
      end

      Status.find_by(uri: uri)
    end

    def mentions_from_xml(parent, xml)
      processed_account_ids = []

      xml.xpath('./xmlns:link[@rel="mentioned"]', xmlns: TagManager::XMLNS).each do |link|
        next if [TagManager::TYPES[:group], TagManager::TYPES[:collection]].include? link['ostatus:object-type']

        mentioned_account = account_from_href(link['href'])

        next if mentioned_account.nil? || processed_account_ids.include?(mentioned_account.id)

        mentioned_account.mentions.where(status: parent).first_or_create(status: parent)

        # So we can skip duplicate mentions
        processed_account_ids << mentioned_account.id
      end
    end

    def account_from_href(href)
      url = Addressable::URI.parse(href)

      if TagManager.instance.web_domain?(url.host)
        Account.find_local(url.path.gsub('/users/', ''))
      else
        Account.find_by(uri: href) || Account.find_by(url: href) || FetchRemoteAccountService.new.call(href)
      end
    end

    def hashtags_from_xml(parent, xml)
      tags = xml.xpath('./xmlns:category', xmlns: TagManager::XMLNS).map { |category| category['term'] }.select(&:present?)
      ProcessHashtagsService.new.call(parent, tags)
    end

    def media_from_xml(parent, xml)
      do_not_download = DomainBlock.find_by(domain: parent.account.domain)&.reject_media?

      xml.xpath('./xmlns:link[@rel="enclosure"]', xmlns: TagManager::XMLNS).each do |link|
        next unless link['href']

        media = MediaAttachment.where(status: parent, remote_url: link['href']).first_or_initialize(account: parent.account, status: parent, remote_url: link['href'])
        parsed_url = URI.parse(link['href'])

        next if !%w[http https].include?(parsed_url.scheme) || parsed_url.host.empty?

        media.save

        next if do_not_download

        begin
          media.file_remote_url = link['href']
          media.save
        rescue OpenURI::HTTPError, Paperclip::Errors::NotIdentifiedByImageMagickError
          next
        end
      end
    end

    def id(xml = @xml)
      xml.at_xpath('./xmlns:id', xmlns: TagManager::XMLNS).content
    end

    def verb(xml = @xml)
      raw = xml.at_xpath('./activity:verb', activity: TagManager::AS_XMLNS).content
      TagManager::VERBS.key(raw)
    rescue
      :post
    end

    def type(xml = @xml)
      raw = xml.at_xpath('./activity:object-type', activity: TagManager::AS_XMLNS).content
      TagManager::TYPES.key(raw)
    rescue
      :activity
    end

    def url(xml = @xml)
      link = xml.at_xpath('./xmlns:link[@rel="alternate"]', xmlns: TagManager::XMLNS)
      link.nil? ? nil : link['href']
    end

    def content(xml = @xml)
      xml.at_xpath('./xmlns:content', xmlns: TagManager::XMLNS).content
    end

    def content_language(xml = @xml)
      xml.at_xpath('./xmlns:content', xmlns: TagManager::XMLNS)['xml:lang']&.presence || 'en'
    end

    def content_warning(xml = @xml)
      xml.at_xpath('./xmlns:summary', xmlns: TagManager::XMLNS)&.content || ''
    end

    def visibility_scope(xml = @xml)
      xml.at_xpath('./mastodon:scope', mastodon: TagManager::MTDN_XMLNS)&.content&.to_sym || :public
    end

    def published(xml = @xml)
      xml.at_xpath('./xmlns:published', xmlns: TagManager::XMLNS).content
    end

    def thread?(xml = @xml)
      !xml.at_xpath('./thr:in-reply-to', thr: TagManager::THR_XMLNS).nil?
    end

    def thread(xml = @xml)
      thr = xml.at_xpath('./thr:in-reply-to', thr: TagManager::THR_XMLNS)
      [thr['ref'], thr['href']]
    end

    def account?(xml = @xml)
      !xml.at_xpath('./xmlns:author', xmlns: TagManager::XMLNS).nil?
    end

    def acct(xml = @xml)
      username = xml.at_xpath('./xmlns:author/xmlns:name', xmlns: TagManager::XMLNS).content
      url      = xml.at_xpath('./xmlns:author/xmlns:uri', xmlns: TagManager::XMLNS).content
      domain   = Addressable::URI.parse(url).host

      "#{username}@#{domain}"
    end
  end
end
