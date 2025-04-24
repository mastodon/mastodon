# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhookPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :create? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, Webhook)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, Webhook)
      end
    end
  end

  permissions :show?, :update?, :enable?, :disable?, :rotate_secret?, :destroy? do
    let(:webhook) { Fabricate(:webhook, events: ['account.created', 'report.created']) }

    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, webhook)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, webhook)
      end
    end
  end
end
