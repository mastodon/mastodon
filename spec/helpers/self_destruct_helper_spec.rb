# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfDestructHelper do
  describe '#self_destruct?' do
    before { Rails.configuration.x.mastodon.self_destruct_value = destruct_value }
    after { Rails.configuration.x.mastodon.self_destruct_value = nil }

    context 'when SELF_DESTRUCT is unset' do
      let(:destruct_value) { nil }

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to an invalid value' do
      let(:destruct_value) { 'true' }

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to value signed for the wrong purpose' do
      let(:destruct_value) { Rails.configuration.x.mastodon.self_destruct_value = Rails.application.message_verifier('foo').generate('example.com') }

      around do |example|
        ClimateControl.modify(
          LOCAL_DOMAIN: 'example.com'
        ) do
          example.run
        end
      end

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to value signed for the wrong domain' do
      let(:destruct_value) { Rails.configuration.x.mastodon.self_destruct_value = Rails.application.message_verifier(described_class::VERIFY_PURPOSE).generate('foo.com') }

      around do |example|
        ClimateControl.modify(
          LOCAL_DOMAIN: 'example.com'
        ) do
          example.run
        end
      end

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to a correctly-signed value' do
      let(:destruct_value) { Rails.configuration.x.mastodon.self_destruct_value = Rails.application.message_verifier(described_class::VERIFY_PURPOSE).generate('example.com') }

      around do |example|
        ClimateControl.modify(
          LOCAL_DOMAIN: 'example.com'
        ) do
          example.run
        end
      end

      it 'returns true' do
        expect(helper.self_destruct?).to be true
      end
    end
  end
end
