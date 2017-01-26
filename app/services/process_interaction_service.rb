# frozen_string_literal: true

class ProcessInteractionService < BaseService
  # Record locally the remote interaction with our user
  # @param [String] envelope Salmon envelope
  # @param [Account] target_account Account the Salmon was addressed to
  def call(envelope, target_account)
    body = salmon.unpack(envelope)

    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    return unless contains_author?(xml)

    username = xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:name', xmlns: TagManager::XMLNS).content
    url      = xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:uri', xmlns: TagManager::XMLNS).content
    domain   = Addressable::URI.parse(url).host
    account  = Account.find_by(username: username, domain: domain)

    if account.nil?
      account = follow_remote_account_service.call("#{username}@#{domain}")
    end

    return if account.suspended?

    if salmon.verify(envelope, account.keypair)
      update_remote_profile_service.call(xml.at_xpath('/xmlns:entry', xmlns: TagManager::XMLNS), account, true)

      case verb(xml)
      when :follow
        follow!(account, target_account) unless target_account.locked? || target_account.blocking?(account)
      when :unfollow
        unfollow!(account, target_account)
      when :favorite
        favourite!(xml, account)
      when :post
        add_post!(body, account) if mentions_account?(xml, target_account)
      when :share
        add_post!(body, account) unless status(xml).nil?
      when :delete
        delete_post!(xml, account)
      when :block
        reflect_block!(account, target_account)
      when :unblock
        reflect_unblock!(account, target_account)
      end
    end
  rescue Goldfinger::Error, HTTP::Error, OStatus2::BadSalmonError
    nil
  end

  private

  def contains_author?(xml)
    !(xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:name', xmlns: TagManager::XMLNS).nil? || xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:uri', xmlns: TagManager::XMLNS).nil?)
  end

  def mentions_account?(xml, account)
    xml.xpath('/xmlns:entry/xmlns:link[@rel="mentioned"]', xmlns: TagManager::XMLNS).each { |mention_link| return true if mention_link.attribute('href').value == TagManager.instance.url_for(account) }
    false
  end

  def verb(xml)
    raw = xml.at_xpath('//activity:verb', activity: TagManager::AS_XMLNS).content
    TagManager::VERBS.key(raw)
  rescue
    :post
  end

  def follow!(account, target_account)
    follow = account.follow!(target_account)
    NotifyService.new.call(target_account, follow)
  end

  def unfollow!(account, target_account)
    account.unfollow!(target_account)
  end

  def reflect_block!(account, target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)
    account.block!(target_account)
  end

  def reflect_unblock!(account, target_account)
    UnblockService.new.call(account, target_account)
  end

  def delete_post!(xml, account)
    status = Status.find(xml.at_xpath('//xmlns:id', xmlns: TagManager::XMLNS).content)

    return if status.nil?

    remove_status_service.call(status) if account.id == status.account_id
  end

  def favourite!(xml, from_account)
    current_status = status(xml)
    favourite = current_status.favourites.where(account: from_account).first_or_create!(account: from_account)
    NotifyService.new.call(current_status.account, favourite)
  end

  def add_post!(body, account)
    process_feed_service.call(body, account)
  end

  def status(xml)
    Status.find(TagManager.instance.unique_tag_to_local_id(activity_id(xml), 'Status'))
  end

  def activity_id(xml)
    xml.at_xpath('//activity:object', activity: TagManager::AS_XMLNS).at_xpath('./xmlns:id', xmlns: TagManager::XMLNS).content
  end

  def salmon
    @salmon ||= OStatus2::Salmon.new
  end

  def follow_remote_account_service
    @follow_remote_account_service ||= FollowRemoteAccountService.new
  end

  def process_feed_service
    @process_feed_service ||= ProcessFeedService.new
  end

  def update_remote_profile_service
    @update_remote_profile_service ||= UpdateRemoteProfileService.new
  end

  def remove_status_service
    @remove_status_service ||= RemoveStatusService.new
  end
end
