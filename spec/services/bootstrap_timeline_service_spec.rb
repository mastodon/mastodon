# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BootstrapTimelineService do
  subject { described_class.new.call(new_user.account) }

  let(:invite)   { nil }
  let(:new_user) { Fabricate(:user, invite_code: invite&.code) }

  context 'when the new user has registered from an invite' do
    let(:autofollow) { false }
    let(:inviter)    { Fabricate(:user, confirmed_at: 2.days.ago) }
    let(:invite)     { Fabricate(:invite, user: inviter, max_uses: nil, expires_at: 1.hour.from_now, autofollow: autofollow) }

    context 'when the invite has auto-follow enabled' do
      let(:autofollow) { true }

      it 'follows the inviter' do
        subject
        expect(new_user.account.following?(inviter.account)).to be true
      end
    end

    context 'when the invite does not have auto-follow enable' do
      let(:autofollow) { false }

      it 'does not follow the inviter' do
        subject
        expect(new_user.account.following?(inviter.account)).to be false
      end
    end
  end
end
