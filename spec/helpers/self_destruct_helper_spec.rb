# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfDestructHelper do
  describe 'self_destruct?' do
    context 'when SELF_DESTRUCT is unset' do
      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to an invalid value' do
      around do |example|
        ClimateControl.modify SELF_DESTRUCT: 'true' do
          example.run
        end
      end

      it 'returns false' do
        expect(helper.self_destruct?).to be false
      end
    end

    context 'when SELF_DESTRUCT is set to value signed for the wrong purpose' do
      around do |example|
        ClimateControl.modify(
          SELF_DESTRUCT: Rails.application.message_verifier('foo').generate('example.com'),
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
      around do |example|
        ClimateControl.modify(
          SELF_DESTRUCT: Rails.application.message_verifier('self-destruct').generate('foo.com'),
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
      around do |example|
        ClimateControl.modify(
          SELF_DESTRUCT: Rails.application.message_verifier('self-destruct').generate('example.com'),
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
