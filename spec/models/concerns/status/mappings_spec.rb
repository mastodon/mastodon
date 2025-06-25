# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::Mappings do
  describe '.bookmarks_map' do
    subject { Status.bookmarks_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    context 'with a bookmarkeded status' do
      before { Fabricate(:bookmark, account: account, status: status) }

      it { is_expected.to be_a(Hash).and include(status.id => true) }
    end
  end

  describe '.favourites_map' do
    subject { Status.favourites_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    context 'with a favourited status' do
      before { Fabricate(:favourite, status: status, account: account) }

      it { is_expected.to be_a(Hash).and include(status.id => true) }
    end
  end

  describe '.mutes_map' do
    subject { Status.mutes_map([status.conversation.id], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    context 'with a muted conversation' do
      before { account.mute_conversation!(status.conversation) }

      it { is_expected.to be_a(Hash).and include(status.conversation_id => true) }
    end
  end

  describe '.pins_map' do
    subject { Status.pins_map([status], account) }

    let(:status)  { Fabricate(:status, account: account) }
    let(:account) { Fabricate(:account) }

    context 'with a pinned status' do
      before { Fabricate(:status_pin, account: account, status: status) }

      it { is_expected.to be_a(Hash).and include(status.id => true) }
    end
  end

  describe '.reblogs_map' do
    subject { Status.reblogs_map([status], account) }

    let(:status)  { Fabricate(:status) }
    let(:account) { Fabricate(:account) }

    context 'with a reblogged status' do
      before { Fabricate(:status, account: account, reblog: status) }

      it { is_expected.to be_a(Hash).and include(status.id => true) }
    end
  end
end
