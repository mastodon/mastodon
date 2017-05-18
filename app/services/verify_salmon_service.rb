# frozen_string_literal: true

class VerifySalmonService < BaseService
  include AuthorExtractor

  def call(payload)
    body = salmon.unpack(payload)

    xml = Nokogiri::XML(body)
    xml.encoding = 'utf-8'

    account = author_from_xml(xml.at_xpath('/xmlns:entry', xmlns: TagManager::XMLNS))

    if account.nil?
      false
    else
      salmon.verify(payload, account.keypair)
    end
  end

  private

  def salmon
    @salmon ||= OStatus2::Salmon.new
  end
end
