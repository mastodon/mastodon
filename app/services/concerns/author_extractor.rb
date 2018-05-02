# frozen_string_literal: true

module AuthorExtractor
  include XmlHelper

  def author_from_xml(xml, update_profile = true)
    return nil if xml.nil?

    # Try <email> for acct
    acct = xml.at_xpath(namespaced_xpath('./xmlns:author/xmlns:email', xmlns: OStatus::TagManager::XMLNS))&.text

    # Try <name> + <uri>
    if acct.blank?
      username = xml.at_xpath(namespaced_xpath('./xmlns:author/xmlns:name', xmlns: OStatus::TagManager::XMLNS))&.text
      uri      = xml.at_xpath(namespaced_xpath('./xmlns:author/xmlns:uri', xmlns: OStatus::TagManager::XMLNS))&.text

      return nil if username.blank? || uri.blank?

      domain = Addressable::URI.parse(uri).normalized_host
      acct   = "#{username}@#{domain}"
    end

    ResolveAccountService.new.call(acct, update_profile)
  end
end
