class ProcessInteractionService
  include ApplicationHelper

  def call(envelope, target_account)
    body = salmon.unpack(envelope)
    xml  = Nokogiri::XML(body)

    return unless involves_target_account?(xml, target_account) && contains_author?(xml)

    username = xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:name').content
    url      = xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:uri').content
    domain   = Addressable::URI.parse(url).host
    account  = Account.find_by(username: username, domain: domain)

    if account.nil?
      account = follow_remote_account_service.("acct:#{username}@#{domain}")
      return if account.nil?
    end

    if salmon.verify(envelope, account.keypair)
      case get_verb(xml)
      when :follow
        account.follow!(target_account)
      when :unfollow
        account.unfollow!(target_account)
      when :favorite
        # todo: a favourite
      when :post
        # todo: a reply
      when :share
        # todo: a reblog
      end
    end
  end

  private

  def contains_author?(xml)
    !(xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:name').nil? || xml.at_xpath('/xmlns:entry/xmlns:author/xmlns:uri').nil?)
  end

  def involves_target_account?(xml, account)
    targeted_at_account?(xml, account) || mentions_account?(xml, account)
  end

  def targeted_at_account?(xml, account)
    target_id = xml.at_xpath('/xmlns:entry/activity:object/xmlns:id')
    !target_id.nil? && target_id.content == profile_url(name: account.username)
  end

  def mentions_account?(xml, account)
    xml.xpath('/xmlns:entry/xmlns:link[@rel="mentioned"]').each do |mention_link|
      return true if mention_link.attribute('ref') == profile_url(name: account.username)
    end

    false
  end

  def get_verb(xml)
    verb = xml.at_xpath('//activity:verb').content.gsub 'http://activitystrea.ms/schema/1.0/', ''
    verb.to_sym
  end

  def salmon
    OStatus2::Salmon.new
  end

  def follow_remote_account_service
    FollowRemoteAccountService.new
  end
end
