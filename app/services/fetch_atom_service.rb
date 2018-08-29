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
    perform_request { |response| process_response(response, terminal) }
  end

  def perform_request(&block)
    accept = 'text/html'
    accept = 'application/activity+json, application/ld+json, application/atom+xml, ' + accept unless @unsupported_activity

    Request.new(:get, @url).add_headers('Accept' => accept).perform(&block)
  end

  def process_response(response, terminal = false)
    return nil if response.code != 200

    if response.mime_type == 'application/atom+xml'
      [@url, { prefetched_body: response.body_with_limit }, :ostatus]
    elsif ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(response.mime_type)
      body = response.body_with_limit
      json = body_to_json(body)
      if supported_context?(json) && equals_or_includes_any?(json['type'], ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES) && json['inbox'].present?
        [json['id'], { prefetched_body: body, id: true }, :activitypub]
      elsif supported_context?(json) && expected_type?(json)
        [json['id'], { prefetched_body: body, id: true }, :activitypub]
      else
        @unsupported_activity = true
        nil
      end
    elsif !terminal
      link_header = response['Link'] && parse_link_header(response)

      if link_header&.find_link(%w(rel alternate))
        process_link_headers(link_header)
      elsif response.mime_type == 'text/html'
        process_html(response)
      end
    end
  end

  def expected_type?(json)
    equals_or_includes_any?(json['type'], ActivityPub::Activity::Create::SUPPORTED_TYPES + ActivityPub::Activity::Create::CONVERTED_TYPES)
  end

  def process_html(response)
    page = Nokogiri::HTML(response.body_with_limit)

    json_link = page.xpath('//link[@rel="alternate"]').find { |link| ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(link['type']) }
    atom_link = page.xpath('//link[@rel="alternate"]').find { |link| link['type'] == 'application/atom+xml' }

    result ||= process(json_link['href'], terminal: true) unless json_link.nil? || @unsupported_activity
    result ||= process(atom_link['href'], terminal: true) unless atom_link.nil?

    result
  end

  def process_link_headers(link_header)
    json_link = link_header.find_link(%w(rel alternate), %w(type application/activity+json)) || link_header.find_link(%w(rel alternate), ['type', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'])
    atom_link = link_header.find_link(%w(rel alternate), %w(type application/atom+xml))

    result ||= process(json_link.href, terminal: true) unless json_link.nil? || @unsupported_activity
    result ||= process(atom_link.href, terminal: true) unless atom_link.nil?

    result
  end

  def parse_link_header(response)
    LinkHeader.parse(response['Link'].is_a?(Array) ? response['Link'].first : response['Link'])
  end
end
