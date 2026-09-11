# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BasePolicy do
  let(:policy) { described_class }
  let(:custom_devops_role) do
    Fabricate(:user_role, permissions_as_keys: [:view_devops])
  end
  let(:custom_role_with_one_admin_permission) do
    Fabricate(:user_role, permissions_as_keys: [:manage_announcements])
  end
  let(:custom_role_with_one_moderator_permission) do
    Fabricate(:user_role, permissions_as_keys: [:manage_invites])
  end
  let(:admin) { Fabricate(:admin_user).account }
  let(:moderator) { Fabricate(:moderator_user).account }
  let(:devops_user) { Fabricate(:user, role: custom_devops_role).account }
  let(:custom_admin) { Fabricate(:user, role: custom_role_with_one_admin_permission).account }
  let(:custom_moderator) { Fabricate(:user, role: custom_role_with_one_moderator_permission).account }
  let(:regular_user) { Fabricate(:account) }

  permissions :access? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, :base)
      end
    end

    context 'with a moderator' do
      it 'permits' do
        expect(policy).to permit(moderator, :base)
      end
    end

    context 'with a user with devops permissions' do
      it 'permits' do
        expect(policy).to permit(devops_user, :base)
      end
    end

    context 'with a user with a custom role that grants a single admin permission' do
      it 'permits' do
        expect(policy).to permit(custom_admin, :base)
      end
    end

    context 'with a user with a custom role that grants a single moderator permission' do
      it 'permits' do
        expect(policy).to permit(custom_moderator, :base)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(regular_user, :base)
      end
    end
  end
end
