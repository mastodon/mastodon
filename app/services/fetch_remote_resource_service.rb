# frozen_string_literal: true

class FetchRemoteResourceService < BaseService
  def call(url)
    atom_url, body = FetchAtomService.new.call(url)

    return nil if atom_url.nil?

    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    if xml.root.name == 'feed'
      FetchRemoteAccountService.new.call(atom_url, body)
    elsif xml.root.name == 'entry'
      FetchRemoteStatusService.new.call(atom_url, body)
    end
  end
end
