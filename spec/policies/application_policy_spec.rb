# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject do
    Class.new(described_class) do
      def spec?
        role.can?(:manage_users)
      end
    end
  end

  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }
  let(:alice)   { Fabricate(:admin_user, disabled: true).account }

  permissions :spec? do
    context 'when staff' do
      it 'permits' do
        expect(subject).to permit(admin)
      end
    end

    context 'when not staff' do
      it 'denies' do
        expect(subject).to_not permit(john)
      end
    end

    context 'when staff but disabled' do
      it 'denies' do
        expect(subject).to_not permit(alice)
      end
    end
  end
end
