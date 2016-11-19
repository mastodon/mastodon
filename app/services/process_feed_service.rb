# frozen_string_literal: true

class ProcessFeedService < BaseService
  ACTIVITY_NS = 'http://activitystrea.ms/spec/1.0/'
  THREAD_NS   = 'http://purl.org/syndication/thread/1.0'

  def call(body, account)
    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    update_author(xml, account)
    process_entries(xml, account)
  end

  private

  def update_author(xml, account)
    return if xml.at_xpath('/xmlns:feed').nil?
    UpdateRemoteProfileService.new.call(xml.at_xpath('/xmlns:feed/xmlns:author'), account)
  end

  def process_entries(xml, account)
    xml.xpath('//xmlns:entry').reverse_each.map { |entry| ProcessEntry.new.call(entry, account) }.compact
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
      status = status_from_xml(@xml)

      if verb == :share
        original_status = status_from_xml(@xml.at_xpath('.//activity:object', activity: ACTIVITY_NS))
        status.reblog   = original_status

        if original_status.nil?
          status.destroy
          return nil
        elsif original_status.reblog?
          status.reblog = original_status.reblog
        end
      end

      status.save!
      Rails.logger.debug "Queuing remote status #{status.id} (#{id}) for distribution"
      DistributionWorker.perform_async(status.id)
      status
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
      return status unless status.nil?

      # If status embeds an author, find that author
      # If that author cannot be found, don't record the status (do not misattribute)
      if account?(entry)
        begin
          account = find_or_resolve_account(acct(entry))
          return nil if account.nil?
        rescue Goldfinger::Error
          return nil
        end
      else
        account = @account
      end

      status = Status.create!(
        uri: id(entry),
        url: url(entry),
        account: account,
        text: content(entry),
        created_at: published(entry)
      )

      if thread?(entry)
        Rails.logger.debug "Trying to attach #{status.id} (#{id(entry)}) to #{thread(entry).first}"
        status.thread = find_or_resolve_status(status, *thread(entry))
      end

      mentions_from_xml(status, entry)
      hashtags_from_xml(status, entry)
      media_from_xml(status, entry)

      status
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

      xml.xpath('./xmlns:link[@rel="mentioned"]').each do |link|
        next if link['href'] == 'http://activityschema.org/collection/public'

        url = Addressable::URI.parse(link['href'])

        mentioned_account = if TagManager.instance.local_domain?(url.host)
                              Account.find_local(url.path.gsub('/users/', ''))
                            else
                              Account.find_by(url: link['href']) || FetchRemoteAccountService.new.call(link['href'])
                            end

        next if mentioned_account.nil? || processed_account_ids.include?(mentioned_account.id)

        mention = mentioned_account.mentions.where(status: parent).first_or_create(status: parent)

        # Notify local user
        NotifyService.new.call(mentioned_account, mention) if mentioned_account.local?

        # So we can skip duplicate mentions
        processed_account_ids << mentioned_account.id
      end
    end

    def hashtags_from_xml(parent, xml)
      tags = xml.xpath('./xmlns:category').map { |category| category['term'] }.select { |t| !t.blank? }
      ProcessHashtagsService.new.call(parent, tags)
    end

    def media_from_xml(parent, xml)
      xml.xpath('./xmlns:link[@rel="enclosure"]').each do |link|
        next unless link['href']

        media = MediaAttachment.where(status: parent, remote_url: link['href']).first_or_initialize(account: parent.account, status: parent, remote_url: link['href'])

        begin
          media.file_remote_url = link['href']
          media.save
        rescue OpenURI::HTTPError, Paperclip::Errors::NotIdentifiedByImageMagickError
          next
        end
      end
    end

    def id(xml = @xml)
      xml.at_xpath('./xmlns:id').content
    end

    def verb(xml = @xml)
      raw = xml.at_xpath('./activity:verb', activity: ACTIVITY_NS).content
      raw.gsub('http://activitystrea.ms/schema/1.0/', '').gsub('http://ostatus.org/schema/1.0/', '').to_sym
    rescue
      :post
    end

    def type(xml = @xml)
      raw = xml.at_xpath('./activity:object-type', activity: ACTIVITY_NS).content
      raw.gsub('http://activitystrea.ms/schema/1.0/', '').gsub('http://ostatus.org/schema/1.0/', '').to_sym
    rescue
      :activity
    end

    def url(xml = @xml)
      link = xml.at_xpath('./xmlns:link[@rel="alternate"]')
      link.nil? ? nil : link['href']
    end

    def content(xml = @xml)
      xml.at_xpath('./xmlns:content').content
    end

    def published(xml = @xml)
      xml.at_xpath('./xmlns:published').content
    end

    def thread?(xml = @xml)
      !xml.at_xpath('./thr:in-reply-to', thr: THREAD_NS).nil?
    end

    def thread(xml = @xml)
      thr = xml.at_xpath('./thr:in-reply-to', thr: THREAD_NS)
      [thr['ref'], thr['href']]
    end

    def account?(xml = @xml)
      !xml.at_xpath('./xmlns:author').nil?
    end

    def acct(xml = @xml)
      username = xml.at_xpath('./xmlns:author/xmlns:name').content
      url      = xml.at_xpath('./xmlns:author/xmlns:uri').content
      domain   = Addressable::URI.parse(url).host

      "#{username}@#{domain}"
    end
  end
end
