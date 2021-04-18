# frozen_string_literal: true

require 'rails_helper'

describe RSS::Serializer do
  describe '#status_title' do
    let(:text)      { 'This is a toot' }
    let(:spoiler)   { '' }
    let(:sensitive) { false }
    let(:reblog)    { nil }
    let(:account)   { Fabricate(:account) }
    let(:status)    { Fabricate(:status, account: account, text: text, spoiler_text: spoiler, sensitive: sensitive, reblog: reblog) }

    subject { RSS::Serializer.new.send(:status_title, status) }

    context 'if destroyed?' do
      it 'returns "#{account.acct} deleted status"' do
        status.destroy!
        expect(subject).to eq "#{account.acct} deleted status"
      end
    end

    context 'on a toot with long text' do
      let(:text) { "This toot's text is longer than the allowed number of characters" }

      it 'truncates toot text appropriately' do
        expect(subject).to eq "#{account.acct}: “This toot's text is longer tha…”"
      end
    end

    context 'on a toot with long text with a newline' do
      let(:text) { "This toot's text is longer\nthan the allowed number of characters" }

      it 'truncates toot text appropriately' do
        expect(subject).to eq "#{account.acct}: “This toot's text is longer…”"
      end
    end

    context 'on a toot with a content warning' do
      let(:spoiler) { 'long toot' }

      it 'displays spoiler text instead of toot content' do
        expect(subject).to eq "#{account.acct}: CW “long toot”"
      end
    end

    context 'on a toot with sensitive media' do
      let(:sensitive) { true }

      it 'displays that the media is sensitive' do
        expect(subject).to eq "#{account.acct}: “This is a toot” (sensitive)"
      end
    end

    context 'on a reblog' do
      let(:reblog) { Fabricate(:status, text: 'This is a toot') }

      it 'display that the toot is a reblog' do
        expect(subject).to eq "#{account.acct} boosted #{reblog.account.acct}: “This is a toot”"
      end
    end
  end
end
