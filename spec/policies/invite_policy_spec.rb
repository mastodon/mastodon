# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvitePolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:user).account }

  permissions :index? do
    context 'when staff?' do
      it 'permits' do
        expect(subject).to permit(admin, Invite)
      end
    end
  end

  permissions :create? do
    context 'with privilege' do
      before do
        UserRole.everyone.update(permissions: UserRole::FLAGS[:invite_users])
      end

      it 'permits' do
        expect(subject).to permit(john, Invite)
      end
    end

    context 'when does not have privilege' do
      before do
        UserRole.everyone.update(permissions: UserRole::Flags::NONE)
      end

      it 'denies' do
        expect(subject).to_not permit(john, Invite)
      end
    end
  end

  permissions :deactivate_all? do
    context 'when admin?' do
      it 'permits' do
        expect(subject).to permit(admin, Invite)
      end
    end

    context 'when not admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, Invite)
      end
    end
  end

  permissions :destroy? do
    context 'when owner?' do
      it 'permits' do
        expect(subject).to permit(john, Fabricate(:invite, user: john.user))
      end
    end

    context 'when not owner?' do
      context 'when admin?' do
        it 'permits' do
          expect(subject).to permit(admin, Fabricate(:invite))
        end
      end

      context 'when not admin?' do
        it 'denies' do
          expect(subject).to_not permit(john, Fabricate(:invite))
        end
      end
    end
  end
end
