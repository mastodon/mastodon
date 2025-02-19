# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppealPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }
  let(:appeal) { Fabricate(:appeal) }

  permissions :index? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, Appeal)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, Appeal)
      end
    end
  end

  permissions :reject?, :approve? do
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
