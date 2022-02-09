# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe DomainBlockPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:user).account }

  permissions :index?, :show?, :create?, :destroy? do
    context 'admin' do
      it 'permits' do
        expect(subject).to permit(admin, DomainBlock)
      end
    end

    context 'not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, DomainBlock)
      end
    end
  end
end
