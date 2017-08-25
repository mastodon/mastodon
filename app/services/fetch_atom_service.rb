# frozen_string_literal: true

class FetchAtomService < BaseService
  include JsonLdHelper

  def call(url)
    return if url.blank?

    result = process(url)

    # retry without ActivityPub
    result ||= process(url) if @unsupported_activity

    result
  rescue OpenSSL::SSL::SSLError => e
    Rails.logger.debug "SSL error: #{e}"
    nil
  rescue HTTP::ConnectionError => e
    Rails.logger.debug "HTTP ConnectionError: #{e}"
    nil
  end

  private

  def process(url, terminal = false)
    @url = url
    perform_request
    process_response(terminal)
  end

  def perform_request
    accept = 'text/html'
    accept = 'application/activity+json, application/ld+json, application/atom+xml, ' + accept unless @unsupported_activity

    @response = Request.new(:get, @url)
                       .add_headers('Accept' => accept)
                       .perform
  end

  def process_response(terminal = false)
    return nil if @response.code != 200

    if @response.mime_type == 'application/atom+xml'
      [@url, @response.to_s, :ostatus]
    elsif ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@response.mime_type)
      if supported_activity?(@response.to_s)
        [@url, @response.to_s, :activitypub]
      else
        @unsupported_activity = true
        nil
      end
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

    result ||= process(json_link['href'], terminal: true) unless json_link.nil? || @unsupported_activity
    result ||= process(atom_link['href'], terminal: true) unless atom_link.nil?

    result
  end

  def process_headers
    link_header = LinkHeader.parse(@response['Link'].is_a?(Array) ? @response['Link'].first : @response['Link'])

    json_link = link_header.find_link(%w(rel alternate), %w(type application/activity+json)) || link_header.find_link(%w(rel alternate), ['type', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'])
    atom_link = link_header.find_link(%w(rel alternate), %w(type application/atom+xml))

    result ||= process(json_link.href, terminal: true) unless json_link.nil? || @unsupported_activity
    result ||= process(atom_link.href, terminal: true) unless atom_link.nil?

    result
  end

  def supported_activity?(body)
    json = body_to_json(body)
    return false unless supported_context?(json)
    json['type'] == 'Person' ? json['inbox'].present? : true
  end
end
