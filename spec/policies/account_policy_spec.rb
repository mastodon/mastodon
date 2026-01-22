# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }
  let(:alice)   { Fabricate(:account) }

  permissions :index? do
    context 'when staff' do
      it 'permits' do
        expect(subject).to permit(admin)
      end
    end

    context 'when not staff' do
      it 'denies' do
        expect(subject).to_not permit(john)
      end
    end
  end

  permissions :show?, :unsilence?, :unsensitive?, :remove_avatar?, :remove_header?, :sensitive?, :warn? do
    context 'when staff' do
      it 'permits' do
        expect(subject).to permit(admin, alice)
      end
    end

    context 'when not staff' do
      it 'denies' do
        expect(subject).to_not permit(john, alice)
      end
    end
  end

  permissions :unsuspend?, :unblock_email? do
    before do
      alice.suspend!
    end

    context 'when staff' do
      it 'permits' do
        expect(subject).to permit(admin, alice)
      end
    end

    context 'when not staff' do
      it 'denies' do
        expect(subject).to_not permit(john, alice)
      end
    end
  end

  permissions :redownload? do
    context 'when admin' do
      it 'permits' do
        expect(subject).to permit(admin)
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john)
      end
    end
  end

  permissions :suspend?, :silence? do
    let(:staff) { Fabricate(:admin_user).account }

    context 'when staff' do
      context 'when record is staff' do
        it 'denies' do
          expect(subject).to_not permit(admin, staff)
        end
      end

      context 'when record is not staff' do
        it 'permits' do
          expect(subject).to permit(admin, john)
        end
      end
    end

    context 'when not staff' do
      it 'denies' do
        expect(subject).to_not permit(john, Account)
      end
    end
  end

  permissions :memorialize? do
    let(:other_admin) { Fabricate(:admin_user).account }

    context 'when admin' do
      context 'when record is admin' do
        it 'denies' do
          expect(subject).to_not permit(admin, other_admin)
        end
      end

      context 'when record is not admin' do
        it 'permits' do
          expect(subject).to permit(admin, john)
        end
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, Account)
      end
    end
  end

  permissions :review? do
    context 'when admin' do
      it 'permits' do
        expect(subject).to permit(admin)
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john)
      end
    end
  end

  permissions :destroy? do
    context 'when admin' do
      context 'with a temporarily suspended account' do
        before { allow(alice).to receive(:suspended_temporarily?).and_return(true) }

        it 'permits' do
          expect(subject).to permit(admin, alice)
        end
      end

      context 'with a not temporarily suspended account' do
        before { allow(alice).to receive(:suspended_temporarily?).and_return(false) }

        it 'denies' do
          expect(subject).to_not permit(admin, alice)
        end
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, alice)
      end
    end
  end

  permissions :feature? do
    context 'when account is featureable?' do
      it 'permits' do
        expect(subject).to permit(alice, john)
      end
    end

    context 'when account is not featureable' do
      before { allow(alice).to receive(:featureable?).and_return(false) }

      it 'denies' do
        expect(subject).to_not permit(john, alice)
      end
    end

    context 'when account is blocked' do
      before { alice.block!(john) }

      it 'denies' do
        expect(subject).to_not permit(alice, john)
      end
    end

    context 'when account is blocking' do
      before { john.block!(alice) }

      it 'denies' do
        expect(subject).to_not permit(alice, john)
      end
    end
  end

  permissions :index_collections? do
    it 'permits when no user is given' do
      expect(subject).to permit(nil, john)
    end

    it 'permits unblocked users' do
      expect(subject).to permit(john, john)
      expect(subject).to permit(alice, john)
    end

    it 'denies blocked users' do
      domain_blocked_user = Fabricate(:remote_account)
      john.block_domain!(domain_blocked_user.domain)
      john.block!(alice)

      expect(subject).to_not permit(domain_blocked_user, john)
      expect(subject).to_not permit(alice, john)
    end
  end
end
