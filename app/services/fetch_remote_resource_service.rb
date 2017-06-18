# frozen_string_literal: true

class FetchRemoteResourceService < BaseService
  attr_reader :url

  def call(url)
    @url = url
    process_url unless fetched_atom_feed.nil?
  end

  private

  def process_url
    case xml_root
    when 'feed'
      FetchRemoteAccountService.new.call(atom_url, body)
    when 'entry'
      FetchRemoteStatusService.new.call(atom_url, body)
    end
  end

  def fetched_atom_feed
    @_fetched_atom_feed ||= FetchAtomService.new.call(url)
  end

  def atom_url
    fetched_atom_feed.first
  end

  def body
    fetched_atom_feed.last
  end

  def xml_root
    xml_data.root.name
  end

  def xml_data
    @_xml_data ||= Nokogiri::XML(body, nil, 'utf-8')
  end
end
