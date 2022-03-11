# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe UserPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:account) }

  permissions :reset_password?, :change_email? do
    context 'staff?' do
      context '!record.staff?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'record.staff?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :disable_2fa? do
    context 'admin?' do
      context '!record.staff?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'record.staff?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context '!admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :confirm? do
    context 'staff?' do
      context '!record.confirmed?' do
        it 'permits' do
          john.user.update(confirmed_at: nil)
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'record.confirmed?' do
        it 'denies' do
          john.user.confirm!
          expect(subject).to_not permit(admin, john.user)
        end
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :enable? do
    context 'staff?' do
      it 'permits' do
        expect(subject).to permit(admin, User)
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :disable? do
    context 'staff?' do
      context '!record.admin?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context 'record.admin?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :promote? do
    context 'admin?' do
      context 'promotable?' do
        it 'permits' do
          expect(subject).to permit(admin, john.user)
        end
      end

      context '!promotable?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context '!admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end

  permissions :demote? do
    context 'admin?' do
      context '!record.admin?' do
        context 'demoteable?' do
          it 'permits' do
            john.user.update(moderator: true)
            expect(subject).to permit(admin, john.user)
          end
        end

        context '!demoteable?' do
          it 'denies' do
            expect(subject).to_not permit(admin, john.user)
          end
        end
      end

      context 'record.admin?' do
        it 'denies' do
          expect(subject).to_not permit(admin, admin.user)
        end
      end
    end

    context '!admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, User)
      end
    end
  end
end
