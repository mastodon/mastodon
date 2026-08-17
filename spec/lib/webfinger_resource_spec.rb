# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebfingerResource do
  around do |example|
    before_local = Rails.configuration.x.local_domain
    before_web = Rails.configuration.x.web_domain
    example.run
    Rails.configuration.x.local_domain = before_local
    Rails.configuration.x.web_domain = before_web
  end

  describe '#account' do
    subject { described_class.new(resource).account }

    describe 'with a URL value' do
      context 'with a route whose controller is not AccountsController' do
        let(:resource) { 'https://example.com/users/alice/other' }

        it 'raises an error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with a string that does not start with an URL' do
        let(:resource) { 'website for http://example.com/users/alice.other' }

        it 'raises an error' do
          expect { subject }.to raise_error(described_class::InvalidRequest)
        end
      end

      context 'with a valid HTTPS route to an existing user' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "https://example.com/users/#{account.username}" }

        it { is_expected.to eq(account) }
      end

      context 'with a valid HTTPS route to an existing user using the new API scheme' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "https://example.com/ap/users/#{account.id}" }

        it { is_expected.to eq(account) }
      end

      context 'with a valid HTTPS route to a non-existing user' do
        let(:account) { Fabricate(:account) }
        let(:resource) { 'https://example.com/users/alice' }

        it 'raises an error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with a mixed case HTTP but valid route to an existing user' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "HTTp://example.com/users/#{account.username}" }

        it { is_expected.to eq(account) }
      end

      context 'with a valid HTTP route to an existing user' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "http://example.com/users/#{account.username}" }

        it { is_expected.to eq(account) }
      end
    end

    describe 'with a username and hostname value' do
      context 'with a non-local domain' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "#{account.username}@remote-host.com" }

        it 'raises an error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with a valid handle for a local user with local domain' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "#{account.username}@example.com" }

        before { Rails.configuration.x.local_domain = 'example.com' }

        it { is_expected.to eq(account) }
      end

      context 'with a valid handle for a local user with web domain' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "#{account.username}@example.com" }

        before { Rails.configuration.x.web_domain = 'example.com' }

        it { is_expected.to eq(account) }
      end
    end

    describe 'with an acct value' do
      context 'with a non-local domain' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "acct:#{account.username}@remote-host.com" }

        it 'raises an error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'with a valid handle for a local user with local domain' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "acct:#{account.username}@example.com" }

        before { Rails.configuration.x.local_domain = 'example.com' }

        it { is_expected.to eq(account) }
      end

      context 'with a valid handle for a local user with web domain' do
        let(:account) { Fabricate(:account) }
        let(:resource) { "acct:#{account.username}@example.com" }

        before { Rails.configuration.x.web_domain = 'example.com' }

        it { is_expected.to eq(account) }
      end
    end

    describe 'with a nonsense resource' do
      let(:resource) { 'df/:dfkj' }

      it 'raises an error' do
        expect { subject }.to raise_error(described_class::InvalidRequest)
      end
    end
  end
end
