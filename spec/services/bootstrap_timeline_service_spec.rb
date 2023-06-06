# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BootstrapTimelineService, type: :service do
  subject { described_class.new }

  context 'when the new user has registered from an invite' do
    let(:service)    { double }
    let(:autofollow) { false }
    let(:inviter)    { Fabricate(:user, confirmed_at: 2.days.ago) }
    let(:invite)     { Fabricate(:invite, user: inviter, max_uses: nil, expires_at: 1.hour.from_now, autofollow: autofollow) }
    let(:new_user)   { Fabricate(:user, invite_code: invite.code) }

    before do
      allow(FollowService).to receive(:new).and_return(service)
      allow(service).to receive(:call)
    end

    context 'when the invite has auto-follow enabled' do
      let(:autofollow) { true }

      it 'calls FollowService to follow the inviter' do
        subject.call(new_user.account)
        expect(service).to have_received(:call).with(new_user.account, inviter.account)
      end
    end

    context 'when the invite does not have auto-follow enable' do
      let(:autofollow) { false }

      it 'calls FollowService to follow the inviter' do
        subject.call(new_user.account)
        expect(service).to_not have_received(:call)
      end
    end
  end
end
