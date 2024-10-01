# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe RelayPolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :update? do
    context 'when admin?' do
      it 'permits' do
        expect(subject).to permit(admin, Relay)
      end
    end

    context 'with !admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, Relay)
      end
    end
  end
end
