# frozen_string_literal: true

require 'rails_helper'

describe InviteValidator do
  let(:user) { Fabricate(:user, created_at: 7.days.ago) }
  let(:invite) { instance_double(Invite, user: user, errors: errors) }
  let(:errors) { instance_double(ActiveModel::Errors, add: nil) }

  describe '#validate' do
    it 'does not add error' do
      subject.validate(invite)
      expect(errors).to_not have_received(:add)
    end

    context 'when active invites limit is reached' do
      before do
        5.times do
          Fabricate(:invite, user: user)
        end
      end

      it 'adds error' do
        subject.validate(invite)
        expect(errors).to have_received(:add)
      end

      context 'when user can bypass limits' do
        let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Moderator')) }

        it 'does not add error' do
          subject.validate(invite)
          expect(errors).to_not have_received(:add)
        end
      end
    end

    context 'when daily limit is reached' do
      before do
        20.times do
          Fabricate(:invite, user: user, expires_at: 10.minutes.ago)
        end
      end

      it 'adds error' do
        subject.validate(invite)
        expect(errors).to have_received(:add)
      end

      context 'when user can bypass limits' do
        let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Moderator')) }

        it 'does not add error' do
          subject.validate(invite)
          expect(errors).to_not have_received(:add)
        end
      end
    end
  end
end
