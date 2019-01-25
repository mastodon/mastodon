# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe InstancePolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:user).account }

  permissions :index? do
    context 'admin' do
      it 'permits' do
        expect(subject).to permit(admin, Instance)
      end
    end

    context 'not admin' do
      it 'denies' do
        expect(subject).to_not permit(john, Instance)
      end
    end
  end
end
