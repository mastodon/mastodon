# frozen_string_literal: true

require 'rails_helper'

describe FetchRemoteResourceService do
  subject { described_class.new }

  describe '#call' do
    it 'returns nil when there is no atom url' do
      url = 'http://example.com/missing-atom'
      service = double
      allow(FetchAtomService).to receive(:new).and_return service
      allow(service).to receive(:call).with(url).and_return(nil)

      result = subject.call(url)
      expect(result).to be_nil
    end

    it 'fetches remote accounts for feed types' do
      url = 'http://example.com/atom-feed'
      service = double
      allow(FetchAtomService).to receive(:new).and_return service
      feed_url = 'http://feed-url'
      feed_content = '<feed>contents</feed>'
      allow(service).to receive(:call).with(url).and_return([feed_url, feed_content])

      account_service = double
      allow(FetchRemoteAccountService).to receive(:new).and_return(account_service)
      allow(account_service).to receive(:call)

      _result = subject.call(url)

      expect(account_service).to have_received(:call).with(feed_url, feed_content, nil)
    end

    it 'fetches remote statuses for entry types' do
      url = 'http://example.com/atom-entry'
      service = double
      allow(FetchAtomService).to receive(:new).and_return service
      feed_url = 'http://feed-url'
      feed_content = '<entry>contents</entry>'
      allow(service).to receive(:call).with(url).and_return([feed_url, feed_content])

      account_service = double
      allow(FetchRemoteStatusService).to receive(:new).and_return(account_service)
      allow(account_service).to receive(:call)

      _result = subject.call(url)

      expect(account_service).to have_received(:call).with(feed_url, feed_content, nil)
    end
  end
end
