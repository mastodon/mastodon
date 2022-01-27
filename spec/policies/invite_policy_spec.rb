# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe InvitePolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:account) }

  permissions :index? do
    context 'staff?' do
      it 'permits' do
        expect(subject).to permit(admin, Invite)
      end
    end
  end

  permissions :create? do
    context 'min_required_role?' do
      it 'permits' do
        allow_any_instance_of(described_class).to receive(:min_required_role?) { true }
        expect(subject).to permit(john, Invite)
      end
    end

    context 'not min_required_role?' do
      it 'denies' do
        allow_any_instance_of(described_class).to receive(:min_required_role?) { false }
        expect(subject).to_not permit(john, Invite)
      end
    end
  end

  permissions :deactivate_all? do
    context 'admin?' do
      it 'permits' do
        expect(subject).to permit(admin, Invite)
      end
    end

    context 'not admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, Invite)
      end
    end
  end

  permissions :destroy? do
    context 'owner?' do
      it 'permits' do
        expect(subject).to permit(john, Fabricate(:invite, user: john.user))
      end
    end

    context 'not owner?' do
      context 'Setting.min_invite_role == "admin"' do
        before do
          Setting.min_invite_role = 'admin'
        end

        context 'admin?' do
          it 'permits' do
            expect(subject).to permit(admin, Fabricate(:invite))
          end
        end

        context 'not admin?' do
          it 'denies' do
            expect(subject).to_not permit(john, Fabricate(:invite))
          end
        end
      end

      context 'Setting.min_invite_role != "admin"' do
        before do
          Setting.min_invite_role = 'else'
        end

        context 'staff?' do
          it 'permits' do
            expect(subject).to permit(admin, Fabricate(:invite))
          end
        end

        context 'not staff?' do
          it 'denies' do
            expect(subject).to_not permit(john, Fabricate(:invite))
          end
        end
      end
    end
  end
end
