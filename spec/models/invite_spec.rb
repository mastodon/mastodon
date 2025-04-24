# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invite do
  it_behaves_like 'Expireable'

  describe 'Associations' do
    it { is_expected.to belong_to(:user).inverse_of(:invites) }
    it { is_expected.to have_many(:users).inverse_of(:invite) }
  end

  describe 'Validations' do
    it { is_expected.to validate_length_of(:comment).is_at_most(described_class::COMMENT_SIZE_LIMIT) }
  end

  describe 'Scopes' do
    describe '.available' do
      let!(:no_expires) { Fabricate :invite, expires_at: nil }
      let!(:past_expires) { Fabricate :invite, expires_at: 2.days.ago }
      let!(:future_expires) { Fabricate :invite, expires_at: 2.days.from_now }

      it 'returns future and non-epiring records' do
        expect(described_class.available)
          .to include(no_expires, future_expires)
          .and not_include(past_expires)
      end
    end
  end

  describe '#valid_for_use?' do
    it 'returns true when there are no limitations' do
      invite = Fabricate(:invite, max_uses: nil, expires_at: nil)
      expect(invite.valid_for_use?).to be true
    end

    it 'returns true when not expired' do
      invite = Fabricate(:invite, max_uses: nil, expires_at: 1.hour.from_now)
      expect(invite.valid_for_use?).to be true
    end

    it 'returns false when expired' do
      invite = Fabricate(:invite, max_uses: nil, expires_at: 1.hour.ago)
      expect(invite.valid_for_use?).to be false
    end

    it 'returns true when uses still available' do
      invite = Fabricate(:invite, max_uses: 250, uses: 249, expires_at: nil)
      expect(invite.valid_for_use?).to be true
    end

    it 'returns false when maximum uses reached' do
      invite = Fabricate(:invite, max_uses: 250, uses: 250, expires_at: nil)
      expect(invite.valid_for_use?).to be false
    end

    it 'returns false when invite creator has been disabled' do
      invite = Fabricate(:invite, max_uses: nil, expires_at: nil)
      invite.user.account.suspend!
      expect(invite.valid_for_use?).to be false
    end
  end

  describe 'Callbacks' do
    describe 'Setting the invite code' do
      context 'when creating a new record' do
        subject { Fabricate.build :invite }

        it 'sets a code value' do
          expect { subject.save }
            .to change(subject, :code).from(be_blank).to(be_present)
        end
      end

      context 'when updating a record' do
        subject { Fabricate :invite }

        it 'does not change the code value' do
          expect { subject.update(max_uses: 123_456) }
            .to not_change(subject, :code)
        end
      end
    end
  end
end
