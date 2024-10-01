# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe InstancePolicy do
  subject { described_class }

  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :show?, :destroy? do
    context 'when admin' do
      it 'permits' do
        expect(subject).to permit(admin, Instance)
      end
    end

    context 'when not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, Instance)
      end
    end
  end
end
