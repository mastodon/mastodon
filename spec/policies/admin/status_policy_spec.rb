# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

describe Admin::StatusPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }
  let(:status) { Fabricate(:status) }

  permissions :index?, :update?, :review?, :destroy? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, Tag)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, Tag)
      end
    end
  end

  permissions :show? do
    context 'with an admin' do
      context 'with a public visible status' do
        before { allow(status).to receive(:public_visibility?).and_return(true) }

        it 'permits' do
          expect(policy).to permit(admin, status)
        end
      end

      context 'with a not public visible status' do
        before { allow(status).to receive(:public_visibility?).and_return(false) }

        it 'denies' do
          expect(policy).to_not permit(admin, status)
        end
      end
    end

    context 'with a non admin' do
      it 'denies' do
        expect(policy).to_not permit(john, status)
      end
    end
  end
end
