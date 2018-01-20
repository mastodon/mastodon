# frozen_string_literal: true

class FetchRemoteResourceService < BaseService
  include JsonLdHelper

  attr_reader :url

  def call(url)
    @url = url

    if TagManager.instance.local_url? url
      TagManager.instance.url_to_resource(url)
    elsif fetched_atom_feed.nil?
      nil
    else
      process_url
    end
  end

  private

  def process_url
    case type
    when 'Person'
      FetchRemoteAccountService.new.call(atom_url, body, protocol)
    when 'Note'
      FetchRemoteStatusService.new.call(atom_url, body, protocol)
    end
  end

  def fetched_atom_feed
    @_fetched_atom_feed ||= FetchAtomService.new.call(url)
  end

  def atom_url
    fetched_atom_feed.first
  end

  def body
    fetched_atom_feed.second[:prefetched_body]
  end

  def protocol
    fetched_atom_feed.third
  end

  def type
    return json_data['type'] if protocol == :activitypub

    case xml_root
    when 'feed'
      'Person'
    when 'entry'
      'Note'
    end
  end

  def json_data
    @_json_data ||= body_to_json(body)
  end

  def xml_root
    xml_data.root.name
  end

  def xml_data
    @_xml_data ||= Nokogiri::XML(body, nil, 'utf-8')
  end

  def check_local_status(status)
    return if status.nil?
    status if status.public_visibility? || status.unlisted_visibility?
  end
end
