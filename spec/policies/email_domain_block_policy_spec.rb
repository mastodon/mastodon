# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe EmailDomainBlockPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:account) }

  permissions :index?, :create?, :destroy? do
    context 'admin' do
      it 'permits' do
        expect(subject).to permit(admin, EmailDomainBlock)
      end
    end

    context 'not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, EmailDomainBlock)
      end
    end
  end
end
