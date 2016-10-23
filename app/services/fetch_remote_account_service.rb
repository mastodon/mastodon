class FetchRemoteAccountService < BaseService
  def call(url)
    atom_url, body = FetchAtomService.new.call(url)

    return nil if atom_url.nil?
    return process_atom(atom_url, body)
  end

  private

  def process_atom(url, body)
    xml       = Nokogiri::XML(body)
    url_parts = Addressable::URI.parse(url)
    username  = xml.at_xpath('//xmlns:author/xmlns:name').try(:content)
    domain    = url_parts.host

    return nil if username.nil?

    Rails.logger.debug "Going to webfinger #{username}@#{domain}"

    return FollowRemoteAccountService.new.call("#{username}@#{domain}")
  rescue TypeError
    Rails.logger.debug "Unparseable URL given: #{url}"
    nil
  rescue Nokogiri::XML::XPath::SyntaxError
    Rails.logger.debug "Invalid XML or missing namespace"
    nil
  end
end
