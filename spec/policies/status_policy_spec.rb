# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusPolicy, type: :model do
  subject { described_class }

  let(:admin) { Fabricate(:admin_user) }
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob) { Fabricate(:account, username: 'bob') }
  let(:status) { Fabricate(:status, account: alice) }

  context 'with the permissions of show? and reblog?' do
    permissions :show?, :reblog? do
      it 'grants access when no viewer' do
        expect(subject).to permit(nil, status)
      end

      it 'denies access when viewer is blocked' do
        block = Fabricate(:block)
        status.visibility = :private
        status.account = block.target_account

        expect(subject).to_not permit(block.account, status)
      end
    end
  end

  context 'with the permission of show?' do
    permissions :show? do
      it 'grants access when direct and account is viewer' do
        status.visibility = :direct

        expect(subject).to permit(status.account, status)
      end

      it 'grants access when direct and viewer is mentioned' do
        status.visibility = :direct
        status.mentions = [Fabricate(:mention, account: alice)]

        expect(subject).to permit(alice, status)
      end

      it 'grants access when direct and non-owner viewer is mentioned and mentions are loaded' do
        status.visibility = :direct
        status.mentions = [Fabricate(:mention, account: bob)]
        status.mentions.load

        expect(subject).to permit(bob, status)
      end

      it 'denies access when direct and viewer is not mentioned' do
        viewer = Fabricate(:account)
        status.visibility = :direct

        expect(subject).to_not permit(viewer, status)
      end

      it 'grants access when private and account is viewer' do
        status.visibility = :private

        expect(subject).to permit(status.account, status)
      end

      it 'grants access when private and account is following viewer' do
        follow = Fabricate(:follow)
        status.visibility = :private
        status.account = follow.target_account

        expect(subject).to permit(follow.account, status)
      end

      it 'grants access when private and viewer is mentioned' do
        status.visibility = :private
        status.mentions = [Fabricate(:mention, account: alice)]

        expect(subject).to permit(alice, status)
      end

      it 'denies access when private and viewer is not mentioned or followed' do
        viewer = Fabricate(:account)
        status.visibility = :private

        expect(subject).to_not permit(viewer, status)
      end
    end
  end

  context 'with the permission of reblog?' do
    permissions :reblog? do
      it 'denies access when private' do
        viewer = Fabricate(:account)
        status.visibility = :private

        expect(subject).to_not permit(viewer, status)
      end

      it 'denies access when direct' do
        viewer = Fabricate(:account)
        status.visibility = :direct

        expect(subject).to_not permit(viewer, status)
      end
    end
  end

  context 'with the permissions of destroy? and unreblog?' do
    permissions :destroy?, :unreblog? do
      it 'grants access when account is deleter' do
        expect(subject).to permit(status.account, status)
      end

      it 'denies access when account is not deleter' do
        expect(subject).to_not permit(bob, status)
      end

      it 'denies access when no deleter' do
        expect(subject).to_not permit(nil, status)
      end
    end
  end

  context 'with the permission of favourite?' do
    permissions :favourite? do
      it 'grants access when viewer is not blocked' do
        follow         = Fabricate(:follow)
        status.account = follow.target_account

        expect(subject).to permit(follow.account, status)
      end

      it 'denies when viewer is blocked' do
        block          = Fabricate(:block)
        status.account = block.target_account

        expect(subject).to_not permit(block.account, status)
      end
    end
  end

  context 'with the permission of update?' do
    permissions :update? do
      it 'grants access if owner' do
        expect(subject).to permit(status.account, status)
      end
    end
  end
end
