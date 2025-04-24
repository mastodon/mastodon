# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mastodon::Feature do
  describe '::testing_only_enabled?' do
    subject { described_class.testing_only_enabled? }

    it { is_expected.to be true }
  end

  describe '::unspecified_feature_enabled?' do
    context 'when example is not tagged with a feature' do
      subject { described_class.unspecified_feature_enabled? }

      it { is_expected.to be false }
    end

    context 'when example is tagged with a feature', feature: 'unspecified_feature' do
      subject { described_class.unspecified_feature_enabled? }

      it { is_expected.to be true }
    end
  end
end
