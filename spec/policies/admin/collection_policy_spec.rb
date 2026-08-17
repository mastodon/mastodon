# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CollectionPolicy do
  let(:policy) { described_class }
  let(:admin) { Fabricate(:admin_user).account }
  let(:john) { Fabricate(:account) }
  let(:collection) { Fabricate(:collection) }

  permissions :index?, :show?, :update?, :destroy? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, Collection)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, Collection)
      end
    end
  end
end
