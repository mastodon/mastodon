# frozen_string_literal: true

require 'rails_helper'

describe RefollowWorker do
  subject { described_class.new }

  let(:account) { Fabricate(:account, domain: 'example.org', protocol: :activitypub) }
  let(:alice)   { Fabricate(:account, domain: nil, username: 'alice') }
  let(:bob)     { Fabricate(:account, domain: nil, username: 'bob') }

  describe 'perform' do
    let(:service) { double }

    before do
      allow(FollowService).to receive(:new).and_return(service)
      allow(service).to receive(:call)

      alice.follow!(account, reblogs: true)
      bob.follow!(account, reblogs: false)
    end

    it 'calls FollowService for local followers' do
      result = subject.perform(account.id)

      expect(result).to be_nil
      expect(service).to have_received(:call).with(alice, account, reblogs: true, notify: false, languages: nil, bypass_limit: true)
      expect(service).to have_received(:call).with(bob, account, reblogs: false, notify: false, languages: nil, bypass_limit: true)
    end
  end
end
