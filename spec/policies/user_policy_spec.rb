# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe UserPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
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
          john.user.confirm!
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
end
