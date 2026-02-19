# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCardPolicy do
  let(:policy) { described_class }
  let(:admin)   { Fabricate(:admin_user).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :review? do
    context 'with an admin' do
      it 'permits' do
        expect(policy).to permit(admin, PreviewCard)
      end
    end

    context 'with a non-admin' do
      it 'denies' do
        expect(policy).to_not permit(john, PreviewCard)
      end
    end
  end
end
