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
      @fetched = Activity.new(xml)

      return unless [:activity, :note, :comment].include?(@fetched.type)

      klass = case @fetched.verb
              when :post
                PostActivity
              when :share
                ShareActivity
              when :delete
                DeletionActivity
              else
                return
              end

      @fetched = klass.new(xml, account)
      @fetched.perform
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug "Nothing was saved for #{id} because: #{e}"
      nil
    end

    class Activity
      def initialize(xml, account = nil)
        @xml = xml
        @account = account
      end

      def verb
        raw = @xml.at_xpath('./activity:verb', activity: TagManager::AS_XMLNS).content
        TagManager::VERBS.key(raw)
      rescue
        :post
      end

      def type
        raw = @xml.at_xpath('./activity:object-type', activity: TagManager::AS_XMLNS).content
        TagManager::TYPES.key(raw)
      rescue
        :activity
      end

      def id
        @xml.at_xpath('./xmlns:id', xmlns: TagManager::XMLNS).content
      end

      def url
        link = @xml.at_xpath('./xmlns:link[@rel="alternate"]', xmlns: TagManager::XMLNS)
        link.nil? ? nil : link['href']
      end

      private

      def find_status(uri)
        if TagManager.instance.local_id?(uri)
          local_id = TagManager.instance.unique_tag_to_local_id(uri, 'Status')
          return Status.find_by(id: local_id)
        end

        Status.find_by(uri: uri)
      end

      def redis
        Redis.current
      end
    end

    class CreationActivity < Activity
      def perform
        if redis.exists("delete_upon_arrival:#{@account.id}:#{id}")
          Rails.logger.debug "Delete for status #{id} was queued, ignoring"
          return
        end

        Rails.logger.debug "Creating remote status #{id}"
        # Return early if status already exists in db
        status = find_status(id)

        return [status, false] unless status.nil?

        return [nil, false] if @account.suspended?

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
          conversation: converstation_to_persistent&.first,
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

      def converstation_to_persistent
        uri = @xml.at_xpath('./ostatus:conversation', ostatus: TagManager::OS_XMLNS)&.attribute('ref')&.content
        return if uri.nil?

        if TagManager.instance.local_id?(uri)
          local_id = TagManager.instance.unique_tag_to_local_id(uri, 'Conversation')
          return Conversation.find_by(id: local_id)
        end

        found = Conversation.find_by(uri: uri)
        found ? [found, false] : [Conversation.create!(uri: uri), true]
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

    class ShareActivity < CreationActivity
      def perform
        status, just_created = super
        NotifyService.new.call(reblog.account, status) if reblog&.account&.local? && just_created
        status
      end

      def object
        @xml.at_xpath('.//activity:object', activity: TagManager::AS_XMLNS)
      end

      private

      def status
        reblog && super
      end

      def reblog
        return @reblog if defined? @reblog

        original_status = RemoteActivity.new(object).perform
        @reblog = original_status.reblog? ? original_status.reblog : original_status
      end
    end

    class PostActivity < CreationActivity
      def perform
        status, just_created = super

        if just_created
          status.mentions.includes(:account).each do |mention|
            mentioned_account = mention.account
            next unless mentioned_account.local?
            NotifyService.new.call(mentioned_account, mention)
          end
        end

        status
      end

      private

      def reblog
        nil
      end
    end

    class DeletionActivity < Activity
      def perform
        Rails.logger.debug "Deleting remote status #{id}"
        status = Status.find_by(uri: id, account: @account)

        if status.nil?
          redis.setex("delete_upon_arrival:#{@account.id}:#{id}", 6 * 3_600, id)
        else
          RemoveStatusService.new.call(status)
        end
      end
    end

    class RemoteActivity < Activity
      def perform
        find_status(id) || FetchRemoteStatusService.new.call(url)
      end
    end
  end
end
