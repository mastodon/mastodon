# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Invitations' do
  describe 'Associations' do
    it { is_expected.to belong_to(:invite).optional.counter_cache(:uses) }
    it { is_expected.to have_many(:invites).inverse_of(:user).dependent(false) }
    it { is_expected.to have_one(:invite_request).inverse_of(:user).dependent(:destroy).class_name(UserInviteRequest) }
  end

  describe 'Validations' do
    subject { Fabricate.build :user }

    context 'when invite request is required by settings' do
      before do
        Setting.require_invite_text = true
        Setting.registrations_mode = 'none'
        subject.invite_id = nil
        subject.external = false
        subject.bypass_registration_checks = false
      end

      it { is_expected.to_not allow_values(nil).for(:invite_request) }
    end
  end

  describe '#invited?' do
    subject { user.invited? }

    let(:user) { Fabricate.build :user }

    context 'when invite is present' do
      before { user.invite = Fabricate(:invite) }

      it { is_expected.to be(true) }
    end

    context 'when invite is not present' do
      before { user.invite = nil }

      it { is_expected.to be(false) }
    end
  end

  describe '#valid_invitation?' do
    subject { user.valid_invitation? }

    let(:user) { Fabricate.build :user }
    let(:invite) { Fabricate :invite }

    context 'when invite is present' do
      before { user.invite = invite }

      context 'when invite is valid for use' do
        before { allow(invite).to receive(:valid_for_use?).and_return(true) }

        it { is_expected.to be(true) }
      end

      context 'when invite is not valid for use' do
        before { allow(invite).to receive(:valid_for_use?).and_return(false) }

        it { is_expected.to be(false) }
      end
    end

    context 'when invite is not present' do
      before { user.invite = nil }

      context 'when invite is valid for use' do
        before { allow(invite).to receive(:valid_for_use?).and_return(true) }

        it { is_expected.to be(false) }
      end

      context 'when invite is not valid for use' do
        before { allow(invite).to receive(:valid_for_use?).and_return(false) }

        it { is_expected.to be(false) }
      end
    end
  end

  describe '#invite_code=' do
    let(:user) { Fabricate.build :user }

    before { user.invite_code = code }

    context 'when code is nil' do
      let(:code) { nil }

      it 'sets invite code to nil and does not populate invite' do
        expect(user.invite)
          .to be_nil
        expect(user.invite_code)
          .to be_nil
      end
    end

    context 'when code is present but does not match an invite' do
      let(:code) { 'ABC123' }

      it 'sets invite code to value and does not populate invite' do
        expect(user.invite)
          .to be_nil
        expect(user.invite_code)
          .to eq(code)
      end
    end

    context 'when code is present and does match an invite' do
      let(:code) { invite.code }
      let(:invite) { Fabricate :invite }

      it 'sets invite code to value and does not populate invite' do
        expect(user.invite)
          .to eq(invite)
        expect(user.invite_code)
          .to eq(code)
      end
    end
  end
end
