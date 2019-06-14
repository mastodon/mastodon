# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe TagPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, admin: true).account }
  let(:john)    { Fabricate(:user).account }

  permissions :index?, :hide?, :unhide? do
    context 'staff?' do
      it 'permits' do
        expect(subject).to permit(admin, Tag)
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, Tag)
      end
    end
  end
end
