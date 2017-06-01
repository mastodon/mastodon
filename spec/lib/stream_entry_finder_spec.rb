# frozen_string_literal: true

require 'rails_helper'

describe StreamEntryFinder do
  include RoutingHelper

  describe '#stream_entry' do
    context 'with a status url' do
      let(:status) { Fabricate(:status) }
      let(:url) { short_account_status_url(account_username: status.account.username, id: status.id) }
      subject { described_class.new(url) }

      it 'finds the stream entry' do
        expect(subject.stream_entry).to eq(status.stream_entry)
      end
    end

    context 'with a stream entry url' do
      let(:stream_entry) { Fabricate(:stream_entry) }
      let(:url) { account_stream_entry_url(stream_entry.account, stream_entry) }
      subject { described_class.new(url) }

      it 'finds the stream entry' do
        expect(subject.stream_entry).to eq(stream_entry)
      end
    end

    context 'with a plausible url' do
      let(:url) { 'https://example.com/users/test/updates/123/embed' }
      subject { described_class.new(url) }

      it 'raises an error' do
        expect { subject.stream_entry }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an unrecognized url' do
      let(:url) { 'https://example.com/about' }
      subject { described_class.new(url) }

      it 'raises an error' do
        expect { subject.stream_entry }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
