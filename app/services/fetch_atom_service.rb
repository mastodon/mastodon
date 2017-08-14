# frozen_string_literal: true

class FetchAtomService < BaseService
  def call(url)
    return if url.blank?

    @url = url

    perform_request
    process_response
  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.debug "SSL error: #{e}"
    nil
  rescue HTTP::ConnectionError => e
    Rails.logger.debug "HTTP ConnectionError: #{e}"
    nil
  end

  private

  def perform_request
    @response = Request.new(:get, @url)
                       .add_headers('Accept' => 'application/activity+json, application/ld+json, application/atom+xml, text/html')
                       .perform
  end

  def process_response(terminal = false)
    return nil if @response.code != 200

    if @response.mime_type == 'application/atom+xml'
      [@url, @response.to_s, :ostatus]
    elsif ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@response.mime_type)
      [@url, @response.to_s, :activitypub]
    elsif @response['Link'] && !terminal
      process_headers
    elsif @response.mime_type == 'text/html' && !terminal
      process_html
    end
  end

  def process_html
    page = Nokogiri::HTML(@response.to_s)

    json_link = page.xpath('//link[@rel="alternate"]').find { |link| ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(link['type']) }
    atom_link = page.xpath('//link[@rel="alternate"]').find { |link| link['type'] == 'application/atom+xml' }

    if !json_link.nil?
      @url = json_link['href']
      perform_request
      process_response(true)
    elsif !atom_link.nil?
      @url = atom_link['href']
      perform_request
      process_response(true)
    end
  end

  def process_headers
    link_header = LinkHeader.parse(@response['Link'].is_a?(Array) ? @response['Link'].first : @response['Link'])

    json_link = link_header.find_link(%w(rel alternate), %w(type application/activity+json)) || link_header.find_link(%w(rel alternate), ['type', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'])
    atom_link = link_header.find_link(%w(rel alternate), %w(type application/atom+xml))

    if !json_link.nil?
      @url = json_link.href
      perform_request
      process_response(true)
    elsif !atom_link.nil?
      @url = atom_link.href
      perform_request
      process_response(true)
    end
  end
end
