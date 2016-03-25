module ApplicationHelper
  def unique_tag(date, id, type)
    "tag:#{Rails.configuration.x.local_domain},#{date.strftime('%Y-%m-%d')}:objectId=#{id}:objectType=#{type}"
  end

  def unique_tag_to_local_id(tag, expected_type)
    matches = Regexp.new("objectId=([\\d]+):objectType=#{expected_type}").match(tag)
    return matches[1] unless matches.nil?
  end

  def local_id?(id)
    id.start_with?("tag:#{Rails.configuration.x.local_domain}")
  end

  def content_for_status(actual_status)
    if actual_status.local?
      linkify(actual_status)
    else
      sanitize(actual_status.content, tags: %w(a br p), attributes: %w(href rel))
    end
  end

  def account_from_mentions(search_string, mentions)
    mentions.each { |x| return x.account if x.account.acct.eql?(search_string) }

    # If that was unsuccessful, try fetching user from db separately
    # But this shouldn't ever happen if the mentions were created correctly!
    username, domain = search_string.split('@')

    if domain == Rails.configuration.x.local_domain
      account = Account.find_local(username)
    else
      account = Account.find_by(username: username, domain: domain)
    end

    account
  end

  def linkify(status)
    auto_link(HTMLEntities.new.encode(status.text), link: :urls, html: { rel: 'nofollow noopener' }).gsub(Account::MENTION_RE) do |m|
      account = account_from_mentions(Account::MENTION_RE.match(m)[1], status.mentions)
      "#{m.split('@').first}<a href=\"#{url_for_target(account)}\" class=\"mention\">@<span>#{account.acct}</span></a>"
    end.html_safe
  end

  def active_nav_class(path)
    current_page?(path) ? 'active' : ''
  end
end
