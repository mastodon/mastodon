# frozen_string_literal: true

class RemoteProfile
  include ActiveModel::Model

  attr_reader :document

  def initialize(body)
    @document = Nokogiri::XML.parse(body, nil, 'utf-8')
  end

  def root
    @root ||= document.at_xpath('/atom:feed|/atom:entry', atom: OStatus::TagManager::XMLNS)
  end

  def author
    @author ||= root.at_xpath('./atom:author|./dfrn:owner', atom: OStatus::TagManager::XMLNS, dfrn: OStatus::TagManager::DFRN_XMLNS)
  end

  def hub_link
    @hub_link ||= link_href_from_xml(root, 'hub')
  end

  def display_name
    @display_name ||= author.at_xpath('./poco:displayName', poco: OStatus::TagManager::POCO_XMLNS)&.content
  end

  def note
    @note ||= author.at_xpath('./atom:summary|./poco:note', atom: OStatus::TagManager::XMLNS, poco: OStatus::TagManager::POCO_XMLNS)&.content
  end

  def scope
    @scope ||= author.at_xpath('./mastodon:scope', mastodon: OStatus::TagManager::MTDN_XMLNS)&.content
  end

  def avatar
    @avatar ||= link_href_from_xml(author, 'avatar')
  end

  def header
    @header ||= link_href_from_xml(author, 'header')
  end

  def locked?
    scope == 'private'
  end

  private

  def link_href_from_xml(xml, type)
    xml.at_xpath(%(./atom:link[@rel="#{type}"]/@href), atom: OStatus::TagManager::XMLNS)&.content
  end
end
