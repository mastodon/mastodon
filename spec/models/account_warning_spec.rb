# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountWarning do
  describe 'Normalizations' do
    describe 'text' do
      it { is_expected.to normalize(:text).from(nil).to('') }
    end
  end

  describe '#appeal_eligible?' do
    context 'when created too long ago' do
      subject { Fabricate.build :account_warning, created_at: (described_class::APPEAL_WINDOW * 2).ago }

      it { is_expected.to_not be_appeal_eligible }
    end

    context 'when created recently' do
      subject { Fabricate.build :account_warning, created_at: (described_class::APPEAL_WINDOW - 2.days).ago }

      it { is_expected.to be_appeal_eligible }
    end
  end
end
