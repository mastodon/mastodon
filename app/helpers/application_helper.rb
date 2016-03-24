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

  def linkify(status)
    mention_hash = {}
    status.mentions.each { |m| mention_hash[m.acct] = m }
    coder = HTMLEntities.new

    auto_link(coder.encode(status.text), link: :urls, html: { rel: 'nofollow noopener' }).gsub(Account::MENTION_RE) do |m|
      account = mention_hash[Account::MENTION_RE.match(m)[1]]
      "#{m.split('@').first}<a href=\"#{url_for_target(account)}\" class=\"mention\">@<span>#{account.acct}</span></a>"
    end.html_safe
  end

  def active_nav_class(path)
    current_page?(path) ? 'active' : ''
  end
end
