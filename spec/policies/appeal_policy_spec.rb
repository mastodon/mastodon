# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

describe AppealPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }
  let(:appeal) { Fabricate(:appeal) }

  permissions :index? do
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

  permissions :reject? do
    context 'with an admin' do
      context 'with a pending appeal' do
        before { allow(appeal).to receive(:pending?).and_return(true) }

        it 'permits' do
          expect(policy).to permit(admin, appeal)
        end
      end

      context 'with a not pending appeal' do
        before { allow(appeal).to receive(:pending?).and_return(false) }

        it 'denies' do
          expect(policy).to_not permit(admin, appeal)
        end
      end
    end

    context 'with a non admin' do
      it 'denies' do
        expect(policy).to_not permit(john, appeal)
      end
    end
  end
end
