# frozen_string_literal: true

require 'rails_helper'
require 'pundit/rspec'

RSpec.describe ReportPolicy do
  let(:subject) { described_class }
  let(:admin)   { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
  let(:john)    { Fabricate(:account) }

  permissions :update?, :index?, :show? do
    context 'staff?' do
      it 'permits' do
        expect(subject).to permit(admin, Report)
      end
    end

    context '!staff?' do
      it 'denies' do
        expect(subject).to_not permit(john, Report)
      end
    end
  end
end
