# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfDestructHelper do
  describe 'self_destruct?' do
    context 'when SELF_DESTRUCT is unset' do
      before { Rails.configuration.x.mastodon.self_destruct_value = nil }
      after { Rails.configuration.x.mastodon.self_destruct_value = nil }

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to an invalid value' do
      before { Rails.configuration.x.mastodon.self_destruct_value = 'true' }
      after { Rails.configuration.x.mastodon.self_destruct_value = nil }

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to value signed for the wrong purpose' do
      before { Rails.configuration.x.mastodon.self_destruct_value = Rails.application.message_verifier('foo').generate('example.com') }
      after { Rails.configuration.x.mastodon.self_destruct_value = nil }

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
      before { Rails.configuration.x.mastodon.self_destruct_value = Rails.application.message_verifier(described_class::VERIFY_PURPOSE).generate('foo.com') }
      after { Rails.configuration.x.mastodon.self_destruct_value = nil }

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
      before { Rails.configuration.x.mastodon.self_destruct_value = Rails.application.message_verifier(described_class::VERIFY_PURPOSE).generate('example.com') }
      after { Rails.configuration.x.mastodon.self_destruct_value = nil }

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
