# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mastodon::Feature do
  around do |example|
    original_value = Rails.configuration.x.mastodon.experimental_features
    Rails.configuration.x.mastodon.experimental_features = 'fasp,fetch_all_replies'
    example.run
    Rails.configuration.x.mastodon.experimental_features = original_value
  end

  describe '::fasp_enabled?' do
    subject { described_class.fasp_enabled? }

    it { is_expected.to be true }
  end

  describe '::fetch_all_replies_enabled?' do
    subject { described_class.fetch_all_replies_enabled? }

    it { is_expected.to be true }
  end

  describe '::unspecified_feature_enabled?' do
    subject { described_class.unspecified_feature_enabled? }

    it { is_expected.to be false }
  end
end
