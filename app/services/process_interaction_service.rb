class ProcessInteractionService
  def call(envelope, target_account)
    body = salmon.unpack(envelope)
    xml  = Nokogiri::XML(body)

    return if !involves_target_account(xml, target_account) || xml.at_xpath('//xmlns:author/xmlns:name').nil? || xml.at_xpath('//xmlns:author/xmlns:uri').nil?

    username = xml.at_xpath('//xmlns:author/xmlns:name').content
    url      = xml.at_xpath('//xmlns:author/xmlns:uri').content
    domain   = Addressable::URI.parse(url).host
    account  = Account.find_by(username: username, domain: domain)

    if account.nil?
      account = follow_remote_account_service.("acct:#{username}@#{domain}")
    end

    if salmon.verify(envelope, account.keypair)
      verb = xml.at_path('//activity:verb').content

      case verb
      when 'http://activitystrea.ms/schema/1.0/follow', 'follow'
        account.follow!(target_account)
      when 'http://activitystrea.ms/schema/1.0/unfollow', 'unfollow'
        account.unfollow!(target_account)
      end
    end
  end

  private

  def involves_target_account(target_account)
    # todo
  end

  def salmon
    OStatus2::Salmon.new
  end

  def follow_remote_account_service
    FollowRemoteAccountService.new
  end
end
