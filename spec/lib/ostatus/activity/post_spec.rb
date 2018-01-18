require 'rails_helper'

RSpec.describe OStatus::Activity::Post do
  it 'persists the status' do
    account = Fabricate(:account)
    xml = entry_xml(account)
    creator = OStatus::Activity::Post.new(xml, account)

    status = creator.perform

    expect(status).to be_present
  end

  it 'persists the license if given' do
    account = Fabricate(:account)
    xml = entry_xml(account, license_url: 'https://creativecommons.org/licenses/by/4.0/')
    creator = OStatus::Activity::Post.new(xml, account)

    status = creator.perform

    expect(status).to be_present
    expect(status.license_url).to eq('https://creativecommons.org/licenses/by/4.0/')
  end

  def entry_xml(account, overrides = {})
    status = Fabricate(:status, overrides)
    ox_xml = OStatus::AtomSerializer.new.feed(account, [status.stream_entry])
    status.destroy!

    parsed_xml = Nokogiri::XML(Ox.dump(ox_xml))
    parsed_xml.at_xpath('//xmlns:entry', xmlns: OStatus::TagManager::XMLNS)
  end
end
