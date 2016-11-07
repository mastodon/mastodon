class ProcessFeedService < BaseService
  ACTIVITY_NS = 'http://activitystrea.ms/spec/1.0/'.freeze
  THREAD_NS   = 'http://purl.org/syndication/thread/1.0'.freeze

  # Create local statuses from an Atom feed
  # @param [String] body Atom feed
  # @param [Account] account Account this feed belongs to
  # @return [Enumerable] created statuses
  def call(body, account)
    xml = Nokogiri::XML(body)
    update_remote_profile_service.call(xml.at_xpath('/xmlns:feed/xmlns:author'), account) unless xml.at_xpath('/xmlns:feed').nil?
    xml.xpath('//xmlns:entry').reverse_each.map { |entry| process_entry(account, entry) }.compact
  end

  private

  def process_entry(account, entry)
    return unless [:note, :comment, :activity].include? object_type(entry)

    status = Status.find_by(uri: activity_id(entry))

    # If we already have a post and the verb is now "delete", we gotta delete it and move on!
    if !status.nil? && verb(entry) == :delete
      delete_post!(status)
      return
    end

    return unless status.nil?

    status = Status.new(uri: activity_id(entry), url: activity_link(entry), account: account, text: content(entry), created_at: published(entry), updated_at: updated(entry))

    if verb(entry) == :share
      add_reblog!(entry, status)
    elsif verb(entry) == :post
      if thread_id(entry).nil?
        add_post!(entry, status)
      else
        add_reply!(entry, status)
      end
    else
      return
    end

    # If we added a status, go through accounts it mentions and create respective relations
    # Also record all media attachments for the status and for the reblogged status if present
    unless status.new_record?
      record_remote_mentions(status, entry.xpath('./xmlns:link[@rel="mentioned"]'))
      record_remote_mentions(status.reblog, entry.at_xpath('./activity:object', activity: ACTIVITY_NS).xpath('./xmlns:link[@rel="mentioned"]')) if status.reblog?

      if status.reblog?
        ProcessHashtagsService.new.call(status.reblog, entry.at_xpath('./activity:object', activity: ACTIVITY_NS).xpath('./xmlns:category').map { |category| category['term'] })
      else
        ProcessHashtagsService.new.call(status, entry.xpath('./xmlns:category').map { |category| category['term'] })
      end

      process_attachments(entry, status)
      process_attachments(entry.xpath('./activity:object', activity: ACTIVITY_NS), status.reblog) if status.reblog?

      Rails.logger.debug "Queuing remote status #{status.id} for distribution"
      DistributionWorker.perform_async(status.id)
      return status
    end
  end

  def record_remote_mentions(status, links)
    return if status.local?

    # Here we have to do a reverse lookup of local accounts by their URL!
    # It's not pretty at all! I really wish all these protocols sticked to
    # using acct:username@domain only! It would make things so much easier
    # and tidier

    links.each do |mention_link|
      href_val = mention_link.attribute('href').value

      next if href_val == 'http://activityschema.org/collection/public'

      href = Addressable::URI.parse(href_val)

      if TagManager.instance.local_domain?(href.host)
        # A local user is mentioned
        mentioned_account = Account.find_local(href.path.gsub('/users/', ''))

        unless mentioned_account.nil?
          mentioned_account.mentions.where(status: status).first_or_create(status: status)
          NotificationMailer.mention(mentioned_account, status).deliver_later unless mentioned_account.blocking?(status.account)
        end
      else
        # What to do about remote user?
        # This is kinda dodgy because URLs could change, we don't index them
        mentioned_account = Account.find_by(url: href.to_s)

        if mentioned_account.nil?
          mentioned_account = FetchRemoteAccountService.new.call(href)
        end

        unless mentioned_account.nil?
          mentioned_account.mentions.where(status: status).first_or_create(status: status)
        end
      end
    end
  end

  def process_attachments(entry, status)
    return if status.local?

    entry.xpath('./xmlns:link[@rel="enclosure"]').each do |enclosure_link|
      next if enclosure_link.attribute('href').nil?

      media = MediaAttachment.where(status: status, remote_url: enclosure_link.attribute('href').value).first

      next unless media.nil?

      begin
        media = MediaAttachment.new(account: status.account, status: status, remote_url: enclosure_link.attribute('href').value)
        media.file_remote_url = enclosure_link.attribute('href').value
        media.save
      rescue Paperclip::Errors::NotIdentifiedByImageMagickError
        Rails.logger.debug "Error saving attachment from #{enclosure_link.attribute('href').value}"
        next
      end
    end
  end

  def add_post!(_entry, status)
    status.save!
  end

  def add_reblog!(entry, status)
    status.reblog = find_original_status(entry, target_id(entry))

    if status.reblog.nil?
      status.reblog = fetch_remote_status(entry)
    end

    if !status.reblog.nil?
      status.save!
      NotificationMailer.reblog(status.reblog, status.account).deliver_later if status.reblog.local? && !status.reblog.account.blocking?(status.account)
    end
  end

  def add_reply!(entry, status)
    status.thread = find_original_status(entry, thread_id(entry))
    status.save!

    if status.thread.nil? && !thread_href(entry).nil?
      ThreadResolveWorker.perform_async(status.id, thread_href(entry))
    end
  end

  def delete_post!(status)
    remove_status_service.call(status)
  end

  def find_original_status(_xml, id)
    return nil if id.nil?

    if TagManager.instance.local_id?(id)
      Status.find(TagManager.instance.unique_tag_to_local_id(id, 'Status'))
    else
      Status.find_by(uri: id)
    end
  end

  def fetch_remote_status(xml)
    username = xml.at_xpath('./activity:object', activity: ACTIVITY_NS).at_xpath('./xmlns:author/xmlns:name').content
    url      = xml.at_xpath('./activity:object', activity: ACTIVITY_NS).at_xpath('./xmlns:author/xmlns:uri').content
    domain   = Addressable::URI.parse(url).host
    account  = Account.find_remote(username, domain)

    if account.nil?
      account = follow_remote_account_service.call("#{username}@#{domain}")
    end

    status = Status.new(account: account, uri: target_id(xml), text: target_content(xml), url: target_url(xml), created_at: published(xml), updated_at: updated(xml))
    status.thread = find_original_status(xml, thread_id(xml))

    if status.save && status.thread.nil? && !thread_href(xml).nil?
      ThreadResolveWorker.perform_async(status.id, thread_href(xml))
    end

    status
  rescue Goldfinger::Error, HTTP::Error
    nil
  end

  def published(xml)
    xml.at_xpath('./xmlns:published').content
  end

  def updated(xml)
    xml.at_xpath('./xmlns:updated').content
  end

  def content(xml)
    xml.at_xpath('./xmlns:content').try(:content)
  end

  def thread_id(xml)
    xml.at_xpath('./thr:in-reply-to', thr: THREAD_NS).attribute('ref').value
  rescue
    nil
  end

  def thread_href(xml)
    xml.at_xpath('./thr:in-reply-to', thr: THREAD_NS).attribute('href').value
  rescue
    nil
  end

  def target_id(xml)
    xml.at_xpath('.//activity:object', activity: ACTIVITY_NS).at_xpath('./xmlns:id').content
  rescue
    nil
  end

  def activity_id(xml)
    xml.at_xpath('./xmlns:id').content
  end

  def activity_link(xml)
    xml.at_xpath('./xmlns:link[@rel="alternate"]').attribute('href').value
  rescue
    ''
  end

  def target_content(xml)
    xml.at_xpath('.//activity:object', activity: ACTIVITY_NS).at_xpath('./xmlns:content').content
  end

  def target_url(xml)
    xml.at_xpath('.//activity:object', activity: ACTIVITY_NS).at_xpath('./xmlns:link[@rel="alternate"]').attribute('href').value
  end

  def object_type(xml)
    xml.at_xpath('./activity:object-type', activity: ACTIVITY_NS).content.gsub('http://activitystrea.ms/schema/1.0/', '').gsub('http://ostatus.org/schema/1.0/', '').to_sym
  rescue
    :activity
  end

  def verb(xml)
    xml.at_xpath('./activity:verb', activity: ACTIVITY_NS).content.gsub('http://activitystrea.ms/schema/1.0/', '').gsub('http://ostatus.org/schema/1.0/', '').to_sym
  rescue
    :post
  end

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end

  def update_remote_profile_service
    @update_remote_profile_service ||= UpdateRemoteProfileService.new
  end

  def remove_status_service
    @remove_status_service ||= RemoveStatusService.new
  end
end
