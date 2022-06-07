# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe SettingsPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:account) }

  permissions :update?, :show? do
    context 'admin?' do
      it 'permits' do
        expect(subject).to permit(admin, Settings)
      end
    end

    context '!admin?' do
      it 'denies' do
        expect(subject).to_not permit(john, Settings)
      end
    end
  end
end
