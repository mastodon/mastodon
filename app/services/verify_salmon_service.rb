# frozen_string_literal: true

class VerifySalmonService < BaseService
  include AuthorExtractor
  include XmlHelper

  def call(payload)
    body = salmon.unpack(payload)

    xml     = Oga.parse_xml(body)
    account = author_from_xml(xml.at_xpath(namespaced_xpath('/xmlns:entry', xmlns: OStatus::TagManager::XMLNS)))

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
