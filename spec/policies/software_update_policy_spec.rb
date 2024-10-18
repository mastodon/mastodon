# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SoftwareUpdatePolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Owner')).account }
  let(:john)    { Fabricate(:account) }

  permissions :index? do
    context 'when owner' do
      it 'permits' do
        expect(subject).to permit(admin, SoftwareUpdate)
      end
    end

    context 'when not owner' do
      it 'denies' do
        expect(subject).to_not permit(john, SoftwareUpdate)
      end
    end
  end
end
