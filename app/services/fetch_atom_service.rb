class FetchAtomService < BaseService
  def call(url)
    response = http_client.head(url)

    Rails.logger.debug "Remote status HEAD request returned code #{response.code}"

    response = http_client.get(url) if response.code == 405

    Rails.logger.debug "Remote status GET request returned code #{response.code}"

    return nil if response.code != 200

    if response.mime_type == 'application/atom+xml'
      return [url, fetch(url)]
    elsif !response['Link'].blank?
      return process_headers(url, response)
    else
      return process_html(fetch(url))
    end

  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.debug "SSL error: #{e}"
  end

  private

  def process_html(body)
    Rails.logger.debug 'Processing HTML'

    page = Nokogiri::HTML(body)
    alternate_link = page.xpath('//link[@rel="alternate"]').find { |link| link['type'] == 'application/atom+xml' }

    return nil if alternate_link.nil?
    return [alternate_link['href'], fetch(alternate_link['href'])]
  end

  def process_headers(url, response)
    Rails.logger.debug 'Processing link header'

    link_header    = LinkHeader.parse(response['Link'].is_a?(Array) ? response['Link'].first : response['Link'])
    alternate_link = link_header.find_link(['rel', 'alternate'], ['type', 'application/atom+xml'])

    return process_html(fetch(url)) if alternate_link.nil?
    return [alternate_link.href, fetch(alternate_link.href)]
  end

  def fetch(url)
    http_client.get(url).to_s
  end

  def http_client
    HTTP.timeout(:per_operation, write: 20, connect: 20, read: 50).follow
  end
end
