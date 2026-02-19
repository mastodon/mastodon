# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionPolicy do
  let(:policy) { described_class }
  let(:collection) { Fabricate(:collection) }
  let(:owner) { collection.account }
  let(:other_user) { Fabricate(:account) }

  permissions :index? do
    it 'permits everyone to index' do
      expect(policy).to permit(nil, Collection)
      expect(policy).to permit(owner, Collection)
    end
  end

  permissions :show? do
    it 'permits when no user is given' do
      expect(policy).to permit(nil, collection)
    end

    it 'permits unblocked users' do
      expect(policy).to permit(owner, collection)
      expect(policy).to permit(other_user, collection)
    end

    it 'denies blocked users' do
      domain_blocked_user = Fabricate(:remote_account)
      owner.block_domain!(domain_blocked_user.domain)
      owner.block!(other_user)

      expect(policy).to_not permit(domain_blocked_user, collection)
      expect(policy).to_not permit(other_user, collection)
    end
  end

  permissions :create? do
    it 'permits any user' do
      expect(policy).to_not permit(nil, Collection)

      expect(policy).to permit(owner, Collection)
      expect(policy).to permit(other_user, Collection)
    end
  end

  permissions :update?, :destroy? do
    it 'only permits the owner' do
      expect(policy).to_not permit(nil, collection)
      expect(policy).to_not permit(other_user, collection)

      expect(policy).to permit(owner, collection)
    end
  end
end
