# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::StatusPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }
  let(:status) { Fabricate(:status, visibility: status_visibility) }
  let(:status_visibility) { :public }

  permissions :index?, :update?, :review?, :destroy? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, Status)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, Status)
      end
    end
  end

  permissions :show? do
    context 'with an admin' do
      context 'with a public visible status' do
        let(:status_visibility) { :public }

        it 'permits' do
          expect(policy).to permit(admin, status)
        end
      end

      context 'with a not public visible status' do
        let(:status_visibility) { :direct }

        it 'denies' do
          expect(policy).to_not permit(admin, status)
        end

        context 'when the status mentions the admin' do
          before do
            status.mentions.create!(account: admin)
          end

          it 'permits' do
            expect(policy).to permit(admin, status)
          end
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
