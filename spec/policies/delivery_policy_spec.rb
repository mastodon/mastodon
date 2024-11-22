# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeliveryPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :clear_delivery_errors?, :restart_delivery?, :stop_delivery? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, nil)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, nil)
      end
    end
  end
end
