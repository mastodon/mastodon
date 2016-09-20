class FetchRemoteStatusService < BaseService
  def call(url)
    response = http_client.head(url)

    Rails.logger.debug "Remote status HEAD request returned code #{response.code}"
    return nil if response.code != 200

    if response.mime_type == 'application/atom+xml'
      return process_atom(url, fetch(url))
    elsif !response['Link'].blank?
      return process_headers(response)
    else
      return process_html(fetch(url))
    end
  end

  private

  def process_atom(url, body)
    Rails.logger.debug "Processing Atom for remote status"

    xml     = Nokogiri::XML(body)
    account = extract_author(url, xml)

    return nil if account.nil?

    statuses = ProcessFeedService.new.(body, account)

    return statuses.first
  end

  def process_html(body)
    Rails.logger.debug "Processing HTML for remote status"

    page = Nokogiri::HTML(body)
    alternate_link = page.xpath('//link[@rel="alternate"]').find { |link| link['type'] == 'application/atom+xml' }

    return nil if alternate_link.nil?
    return process_atom(alternate_link['href'], fetch(alternate_link['href']))
  end

  def process_headers(response)
    Rails.logger.debug "Processing link header for remote status"

    link_header    = LinkHeader.parse(response['Link'])
    alternate_link = link_header.find_link(['rel', 'alternate'], ['type', 'application/atom+xml'])

    return nil if alternate_link.nil?
    return process_atom(alternate_link.href, fetch(alternate_link.href))
  end

  def extract_author(url, xml)
    url_parts = Addressable::URI.parse(url)
    username  = xml.at_xpath('//xmlns:author/xmlns:name').try(:content)
    domain    = url_parts.host

    return nil if username.nil?

    Rails.logger.debug "Going to webfinger #{username}@#{domain}"

    return FollowRemoteAccountService.new.("#{username}@#{domain}")
  end

  def fetch(url)
    http_client.get(url).to_s
  end

  def http_client
    HTTP.timeout(:per_operation, write: 20, connect: 20, read: 50)
  end
end
