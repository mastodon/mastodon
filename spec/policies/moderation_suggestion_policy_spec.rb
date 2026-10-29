# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModerationSuggestionPolicy do
  subject { described_class }

  let(:account) { Fabricate(:account) }
  let(:admin) { Fabricate(:admin_user).account }

  permissions :index?, :show?, :dismiss?, :apply? do
    context 'when admin' do
      it { is_expected.to permit(admin, ModerationSuggestion) }
    end

    context 'when not admin' do
      it { is_expected.to_not permit(account, ModerationSuggestion) }
    end
  end
end
