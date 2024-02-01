# frozen_string_literal: true

class FetchResourceService < BaseService
  include JsonLdHelper

  ACCEPT_HEADER = 'application/activity+json, application/ld+json; profile="https://www.w3.org/ns/activitystreams", text/html;q=0.1'
  ACTIVITY_STREAM_LINK_TYPES = ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].freeze

  attr_reader :response_code

  def call(url)
    return if url.blank?

    process(url)
  rescue HTTP::Error, OpenSSL::SSL::SSLError, Addressable::URI::InvalidURIError, Mastodon::HostValidationError, Mastodon::LengthValidationError => e
    Rails.logger.debug { "Error fetching resource #{@url}: #{e}" }
    nil
  end

  private

  def process(url, terminal: false)
    @url = url

    perform_request { |response| process_response(response, terminal) }
  end

  def perform_request(&block)
    Request.new(:get, @url).tap do |request|
      request.add_headers('Accept' => ACCEPT_HEADER)

      # In a real setting we want to sign all outgoing requests,
      # in case the remote server has secure mode enabled and requires
      # authentication on all resources. However, during development,
      # sending request signatures with an inaccessible host is useless
      # and prevents even public resources from being fetched, so
      # don't do it

      request.on_behalf_of(Account.representative) unless Rails.env.development?
    end.perform(&block)
  end

  def process_response(response, terminal = false)
    @response_code = response.code
    return nil if response.code != 200

    if ['application/activity+json', 'application/ld+json'].include?(response.mime_type)
      body = response.body_with_limit
      json = body_to_json(body)

      return unless supported_context?(json) && (equals_or_includes_any?(json['type'], ActivityPub::FetchRemoteActorService::SUPPORTED_TYPES) || expected_type?(json))

      if json['id'] != @url
        return if terminal

        return process(json['id'], terminal: true)
      end

      [@url, { prefetched_body: body }]
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
    page      = Nokogiri::HTML(response.body_with_limit)
    json_link = page.xpath('//link[@rel="alternate"]').find { |link| ACTIVITY_STREAM_LINK_TYPES.include?(link['type']) }

    process(json_link['href'], terminal: true) unless json_link.nil?
  end

  def process_link_headers(link_header)
    json_link = link_header.find_link(%w(rel alternate), %w(type application/activity+json)) || link_header.find_link(%w(rel alternate), ['type', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'])

    process(json_link.href, terminal: true) unless json_link.nil?
  end

  def parse_link_header(response)
    LinkHeader.parse(response['Link'].is_a?(Array) ? response['Link'].first : response['Link'])
  end
end
