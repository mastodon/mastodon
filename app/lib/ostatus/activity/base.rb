# frozen_string_literal: true

class OStatus::Activity::Base
  def initialize(xml, account = nil)
    @xml = xml
    @account = account
  end

  def status?
    [:activity, :note, :comment].include?(type)
  end

  def verb
    raw = @xml.at_xpath('./activity:verb', activity: TagManager::AS_XMLNS).content
    TagManager::VERBS.key(raw)
  rescue
    :post
  end

  def type
    raw = @xml.at_xpath('./activity:object-type', activity: TagManager::AS_XMLNS).content
    TagManager::TYPES.key(raw)
  rescue
    :activity
  end

  def id
    @xml.at_xpath('./xmlns:id', xmlns: TagManager::XMLNS).content
  end

  def url
    link = @xml.xpath('./xmlns:link[@rel="alternate"]', xmlns: TagManager::XMLNS).find { |link_candidate| link_candidate['type'] == 'text/html' }
    link.nil? ? nil : link['href']
  end

  def activitypub_uri
    link = @xml.xpath('./xmlns:link[@rel="alternate"]', xmlns: TagManager::XMLNS).find { |link_candidate| ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(link_candidate['type']) }
    link.nil? ? nil : link['href']
  end

  def activitypub_uri?
    activitypub_uri.present?
  end

  private

  def find_status(uri)
    if TagManager.instance.local_id?(uri)
      local_id = TagManager.instance.unique_tag_to_local_id(uri, 'Status')
      return Status.find_by(id: local_id)
    elsif ActivityPub::TagManager.instance.local_uri?(uri)
      local_id = ActivityPub::TagManager.instance.uri_to_local_id(uri)
      return Status.find_by(id: local_id)
    end

    Status.find_by(uri: uri)
  end

  def redis
    Redis.current
  end
end
