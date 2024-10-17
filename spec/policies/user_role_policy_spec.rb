# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRolePolicy do
  subject { described_class }

  let(:admin) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:account) { Fabricate(:account) }

  permissions :index?, :create? do
    context 'when admin' do
      it { is_expected.to permit(admin, UserRole.new) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, UserRole.new) }
    end
  end

  permissions :update? do
    context 'when admin' do
      context 'when role of admin overrides relevant role' do
        it { is_expected.to permit(admin, UserRole.new(position: admin.user.role.position - 10, id: 123)) }
      end

      context 'when role of admin does not override relevant role' do
        it { is_expected.to_not permit(admin, UserRole.new(position: admin.user.role.position + 10, id: 123)) }
      end
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, UserRole.new) }
    end
  end

  permissions :destroy? do
    context 'when admin' do
      context 'when role of admin overrides relevant role' do
        it { is_expected.to permit(admin, UserRole.new(position: admin.user.role.position - 10)) }
      end

      context 'when role of admin does not override relevant role' do
        it { is_expected.to_not permit(admin, UserRole.new(position: admin.user.role.position + 10)) }
      end

      context 'when everyone role' do
        it { is_expected.to_not permit(admin, UserRole.everyone) }
      end
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, UserRole.new) }
    end
  end
end
