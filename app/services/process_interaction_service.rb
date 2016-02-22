class ProcessInteractionService
  def call(envelope, target_account)
    body = salmon.unpack(envelope)
    xml  = Nokogiri::XML(body)

    return if !involves_target_account(xml, target_account) || xml.at_xpath('//author/name').nil? || xml.at_xpath('//author/uri').nil?

    username = xml.at_xpath('//author/name').content
    url      = xml.at_xpath('//author/uri').content
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
  end

  def salmon
    OStatus2::Salmon.new
  end

  def follow_remote_account_service
    FollowRemoteAccountService.new
  end
end
