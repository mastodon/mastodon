# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmailDomainBlockPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :show?, :create?, :destroy? do
    context 'when admin' do
      it 'permits' do
        expect(subject).to permit(admin, EmailDomainBlock)
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, EmailDomainBlock)
      end
    end
  end
end
