# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }

  permissions :reset_password?, :change_email? do
    context 'when staff?' do
      context 'with !record.staff?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'when record.staff?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :disable_2fa? do
    context 'when admin?' do
      context 'with !record.staff?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'when record.staff?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context 'with !admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :confirm? do
    context 'when staff?' do
      context 'with !record.confirmed?' do
        it 'permits' do
          john.user.update(confirmed_at: nil)
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'when record.confirmed?' do
        it 'denies' do
          john.user.mark_email_as_confirmed!
          expect(subject).to_not permit(admin, john.user)
        end
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :enable? do
    context 'when staff?' do
      it 'permits' do
        expect(subject).to permit(admin, User)
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :disable? do
    context 'when staff?' do
      context 'with !record.admin?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'when record.admin?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context 'with !staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :approve?, :reject? do
    context 'when admin' do
      context 'when user is approved' do
        it { is_expected.to_not permit(admin, User.new(approved: true)) }
      end

      context 'when user is not approved' do
        it { is_expected.to permit(admin, User.new(approved: false)) }
      end
    end

    context 'when not admin' do
      it { is_expected.to_not permit(john, User.new) }
    end
  end

  permissions :change_role? do
    context 'when not admin' do
      it { is_expected.to_not permit(john, User.new) }
    end

    context 'when admin' do
      let(:user) { User.new(role: role) }

      context 'when role of admin overrides user role' do
        let(:role) { UserRole.new(position: admin.user.role.position - 10, id: 123) }

        it { is_expected.to permit(admin, user) }
      end

      context 'when role of admin does not override user role' do
        let(:role) { UserRole.new(position: admin.user.role.position + 10, id: 123) }

        it { is_expected.to_not permit(admin, user) }
      end
    end
  end
end
