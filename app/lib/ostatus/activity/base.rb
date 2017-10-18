# frozen_string_literal: true

class OStatus::Activity::Base
  def initialize(xml, account = nil, options = {})
    @xml     = xml
    @account = account
    @options = options
  end

  def status?
    [:activity, :note, :comment].include?(type)
  end

  def verb
    raw = @xml.at_xpath('./activity:verb', activity: OStatus::TagManager::AS_XMLNS).content
    OStatus::TagManager::VERBS.key(raw)
  rescue
    :post
  end

  def type
    raw = @xml.at_xpath('./activity:object-type', activity: OStatus::TagManager::AS_XMLNS).content
    OStatus::TagManager::TYPES.key(raw)
  rescue
    :activity
  end

  def id
    @xml.at_xpath('./xmlns:id', xmlns: OStatus::TagManager::XMLNS).content
  end

  def url
    link = @xml.xpath('./xmlns:link[@rel="alternate"]', xmlns: OStatus::TagManager::XMLNS).find { |link_candidate| link_candidate['type'] == 'text/html' }
    link.nil? ? nil : link['href']
  end

  def activitypub_uri
    link = @xml.xpath('./xmlns:link[@rel="alternate"]', xmlns: OStatus::TagManager::XMLNS).find { |link_candidate| ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(link_candidate['type']) }
    link.nil? ? nil : link['href']
  end

  def activitypub_uri?
    activitypub_uri.present?
  end

  private

  def find_status(uri)
    if OStatus::TagManager.instance.local_id?(uri)
      local_id = OStatus::TagManager.instance.unique_tag_to_local_id(uri, 'Status')
      return Status.find_by(id: local_id)
    elsif ActivityPub::TagManager.instance.local_uri?(uri)
      local_id = ActivityPub::TagManager.instance.uri_to_local_id(uri)
      return Status.find_by(id: local_id)
    end

    Status.find_by(uri: uri)
  end

  def find_activitypub_status(uri, href)
    tag_matches = /tag:([^,:]+)[^:]*:objectId=([\d]+)/.match(uri)
    href_matches = %r{/users/([^/]+)}.match(href)

    unless tag_matches.nil? || href_matches.nil?
      uri = "https://#{tag_matches[1]}/users/#{href_matches[1]}/statuses/#{tag_matches[2]}"
      Status.find_by(uri: uri)
    end
  end

  def redis
    Redis.current
  end
end
