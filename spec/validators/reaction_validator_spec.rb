# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReactionValidator do
  subject { Fabricate.build :announcement_reaction }

  context 'when not valid unicode emoji' do
    it { is_expected.to_not allow_value('F').for(:name).with_message(I18n.t('reactions.errors.unrecognized_emoji')) }
  end

  context 'when non-unicode emoji is a custom emoji' do
    let!(:custom_emoji) { Fabricate :custom_emoji }

    it { is_expected.to allow_value(custom_emoji.shortcode).for(:name) }
  end

  describe 'limiting reactions' do
    subject { Fabricate.build :announcement_reaction, announcement: }

    let(:announcement) { Fabricate :announcement }

    before { stub_const 'ReactionValidator::LIMIT', 2 }

    context 'when limit has been reached' do
      before { %w(🐘 ❤️).each { |name| Fabricate :announcement_reaction, name:, announcement: } }

      context 'with emoji already used' do
        it { is_expected.to allow_value('❤️').for(:name) }
      end

      context 'with emoji not already used' do
        it { is_expected.to_not allow_value('😘').for(:name).against(:base).with_message(I18n.t('reactions.errors.limit_reached')) }
      end
    end
  end
end
