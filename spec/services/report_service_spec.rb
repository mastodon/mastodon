require 'rails_helper'

RSpec.describe ReportService, type: :service do
  subject { described_class.new }

  let(:source_account) { Fabricate(:account) }

  context 'for a remote account' do
    let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    end

    it 'sends ActivityPub payload when forward is true' do
      subject.call(source_account, remote_account, forward: true)
      expect(a_request(:post, 'http://example.com/inbox')).to have_been_made
    end

    it 'does not send anything when forward is false' do
      subject.call(source_account, remote_account, forward: false)
      expect(a_request(:post, 'http://example.com/inbox')).to_not have_been_made
    end
  end
end
