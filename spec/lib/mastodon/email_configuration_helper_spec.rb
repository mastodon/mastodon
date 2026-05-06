# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mastodon::EmailConfigurationHelper do
  describe '#convert_smtp_settings' do
    subject { described_class }

    let(:converted_settings) { subject.convert_smtp_settings(configuration) }
    let(:base_configuration) do
      {
        address: 'localhost',
        port: 25,
        user_name: 'mastodon',
        password: 'mastodon',
      }
    end

    context 'when `enable_starttls` is "always"' do
      let(:configuration) do
        base_configuration.merge({ enable_starttls: 'always' })
      end

      it 'converts this to `:always`' do
        expect(converted_settings[:enable_starttls]).to eq :always
        expect(converted_settings[:enable_starttls_auto]).to be_nil
      end
    end

    context 'when `enable_starttls` is "never"' do
      let(:configuration) do
        base_configuration.merge({ enable_starttls: 'never' })
      end

      it 'converts this to `false`' do
        expect(converted_settings[:enable_starttls]).to be false
        expect(converted_settings[:enable_starttls_auto]).to be_nil
      end
    end

    context 'when `enable_starttls` is "auto"' do
      let(:configuration) do
        base_configuration.merge({ enable_starttls: 'auto' })
      end

      it 'sets `enable_starttls` to `:auto`' do
        expect(converted_settings[:enable_starttls]).to eq :auto
        expect(converted_settings[:enable_starttls_auto]).to be_nil
      end
    end

    context 'when `enable_starttls` is unset' do
      context 'when `enable_starttls_auto` is true' do
        let(:configuration) do
          base_configuration.merge({ enable_starttls_auto: true })
        end

        it 'sets `enable_starttls` to `:auto`' do
          expect(converted_settings[:enable_starttls]).to eq :auto
          expect(converted_settings[:enable_starttls_auto]).to be_nil
        end
      end

      context 'when `tls` is set to true' do
        let(:configuration) do
          base_configuration.merge({ tls: true })
        end

        it 'sets `enable_starttls` to `nil`' do
          expect(converted_settings[:enable_starttls]).to be_nil
          expect(converted_settings[:enable_starttls_auto]).to be_nil
        end
      end

      context 'when `enable_starttls_auto` is set to false' do
        let(:configuration) do
          base_configuration.merge({ enable_starttls_auto: false })
        end

        it 'sets `enable_starttls` to `false`' do
          expect(converted_settings[:enable_starttls]).to be false
          expect(converted_settings[:enable_starttls_auto]).to be_nil
        end
      end
    end

    context 'when `authentication` is set to "none"' do
      let(:configuration) do
        base_configuration.merge({ authentication: 'none' })
      end

      it 'sets `authentication` to `nil`' do
        expect(converted_settings[:authentication]).to be_nil
      end
    end

    context 'when `authentication` is set to `login`' do
      let(:configuration) do
        base_configuration.merge({ authentication: 'login' })
      end

      it 'is left as-is' do
        expect(converted_settings[:authentication]).to eq 'login'
      end
    end

    context 'when `authentication` is unset' do
      let(:configuration) { base_configuration }

      it 'sets `authentication` to "plain"' do
        expect(converted_settings[:authentication]).to eq 'plain'
      end
    end
  end
end
