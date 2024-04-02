# frozen_string_literal: true

require 'rails_helper'

describe WebfingerResource do
  around do |example|
    before_local = Rails.configuration.x.local_domain
    before_web = Rails.configuration.x.web_domain
    example.run
    Rails.configuration.x.local_domain = before_local
    Rails.configuration.x.web_domain = before_web
  end

  describe '#username' do
    describe 'with a URL value' do
      it 'raises with a route whose controller is not AccountsController' do
        resource = 'https://example.com/users/alice/other'

        expect do
          described_class.new(resource).username
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises with a route whose action is not show' do
        resource = 'https://example.com/users/alice'

        recognized = Rails.application.routes.recognize_path(resource)
        allow(recognized).to receive(:[]).with(:controller).and_return('accounts')
        allow(recognized).to receive(:[]).with(:username).and_return('alice')
        allow(recognized).to receive(:[]).with(:action).and_return('create')

        allow(Rails.application.routes).to receive(:recognize_path).with(resource).and_return(recognized)

        expect do
          described_class.new(resource).username
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(recognized).to have_received(:[]).exactly(3).times

        expect(Rails.application.routes).to have_received(:recognize_path)
          .with(resource)
          .at_least(:once)
      end

      it 'raises with a string that doesnt start with URL' do
        resource = 'website for http://example.com/users/alice/other'

        expect do
          described_class.new(resource).username
        end.to raise_error(described_class::InvalidRequest)
      end

      it 'finds the username in a valid https route' do
        resource = 'https://example.com/users/alice'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end

      it 'finds the username in a mixed case http route' do
        resource = 'HTTp://exAMPLe.com/users/alice'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end

      it 'finds the username in a valid http route' do
        resource = 'http://example.com/users/alice'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end
    end

    describe 'with a username and hostname value' do
      it 'raises on a non-local domain' do
        resource = 'user@remote-host.com'

        expect do
          described_class.new(resource).username
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'finds username for a local domain' do
        Rails.configuration.x.local_domain = 'example.com'
        resource = 'alice@example.com'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end

      it 'finds username for a web domain' do
        Rails.configuration.x.web_domain = 'example.com'
        resource = 'alice@example.com'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end
    end

    describe 'with an acct value' do
      it 'raises on a non-local domain' do
        resource = 'acct:user@remote-host.com'

        expect do
          described_class.new(resource).username
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises on a nonsense domain' do
        resource = 'acct:user@remote-host@remote-hostess.remote.local@remote'

        expect do
          described_class.new(resource).username
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'finds the username for a local account if the domain is the local one' do
        Rails.configuration.x.local_domain = 'example.com'
        resource = 'acct:alice@example.com'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end

      it 'finds the username for a local account if the domain is the Web one' do
        Rails.configuration.x.web_domain = 'example.com'
        resource = 'acct:alice@example.com'

        result = described_class.new(resource).username
        expect(result).to eq 'alice'
      end
    end

    describe 'with a nonsense resource' do
      it 'raises InvalidRequest' do
        resource = 'df/:dfkj'

        expect do
          described_class.new(resource).username
        end.to raise_error(described_class::InvalidRequest)
      end
    end
  end
end
