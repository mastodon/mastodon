class ProcessInteractionService < BaseService
  # Record locally the remote interaction with our user
  # @param [String] envelope Salmon envelope
  # @param [Account] target_account Account the Salmon was addressed to
  def call(envelope, target_account)
    body = salmon.unpack(envelope)
    xml  = Nokogiri::XML(body)

    return unless contains_author?(xml)

    username = xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:name').content
    url      = xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:uri').content
    domain   = Addressable::URI.parse(url).host
    account  = Account.find_by(username: username, domain: domain)

    if account.nil?
      account = follow_remote_account_service.call("#{username}@#{domain}")
    end

    if salmon.verify(envelope, account.keypair)
      update_remote_profile_service.call(xml.at_xpath('/xmlns:entry/xmlns:author'), account)

      case verb(xml)
      when :follow
        follow!(account, target_account)
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
      end
    end
  rescue Goldfinger::Error, HTTP::Error, OStatus2::BadSalmonError
    nil
  end

  private

  def contains_author?(xml)
    !(xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:name').nil? || xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:uri').nil?)
  end

  def mentions_account?(xml, account)
    xml.xpath('/xmlns:entry/xmlns:link[@rel="mentioned"]').each { |mention_link| return true if mention_link.attribute('href').value == TagManager.instance.url_for(account) }
    false
  end

  def verb(xml)
    xml.at_xpath('//activity:verb').content.gsub('http://activitystrea.ms/schema/1.0/', '').gsub('http://ostatus.org/schema/1.0/', '').to_sym
  rescue
    :post
  end

  def follow!(account, target_account)
    account.follow!(target_account)
    NotificationMailer.follow(target_account, account).deliver_later unless target_account.blocking?(account)
  end

  def unfollow!(account, target_account)
    account.unfollow!(target_account)
  end

  def delete_post!(xml, account)
    status = Status.find(activity_id(xml))

    return if status.nil?

    if account.id == status.account_id
      remove_status_service.call(status)
    end
  end

  def favourite!(xml, from_account)
    current_status = status(xml)
    current_status.favourites.where(account: from_account).first_or_create!(account: from_account)
    NotificationMailer.favourite(current_status, from_account).deliver_later unless current_status.account.blocking?(from_account)
  end

  def add_post!(body, account)
    process_feed_service.call(body, account)
  end

  def status(xml)
    Status.find(TagManager.instance.unique_tag_to_local_id(activity_id(xml), 'Status'))
  end

  def activity_id(xml)
    xml.at_xpath('//activity:object/xmlns:id').content
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
