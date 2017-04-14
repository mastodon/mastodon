require 'rails_helper'

describe WebfingerResource do
  around do |example|
    before = Rails.configuration.x.local_domain
    example.run
    Rails.configuration.x.local_domain = before
  end

  describe '#username' do
    describe 'with a URL value' do
      it 'raises with an unrecognized route' do
        resource = 'https://example.com/users/alice/other'

        expect {
          WebfingerResource.new(resource).username
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises with a string that doesnt start with URL' do
        resource = 'website for http://example.com/users/alice/other'

        expect {
          WebfingerResource.new(resource).username
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'finds the username in a valid https route' do
        resource = 'https://example.com/users/alice'

        result = WebfingerResource.new(resource).username
        expect(result).to eq 'alice'
      end

      it 'finds the username in a mixed case http route' do
        resource = 'HTTp://exAMPLEe.com/users/alice'

        result = WebfingerResource.new(resource).username
        expect(result).to eq 'alice'
      end

      it 'finds the username in a valid http route' do
        resource = 'http://example.com/users/alice'

        result = WebfingerResource.new(resource).username
        expect(result).to eq 'alice'
      end
    end

    describe 'with a username and hostname value' do
      it 'raises on a non-local domain' do
        resource = 'user@remote-host.com'

        expect {
          WebfingerResource.new(resource).username
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'finds username for a local domain' do
        Rails.configuration.x.local_domain = 'example.com'
        resource = 'alice@example.com'

        result = WebfingerResource.new(resource).username
        expect(result).to eq 'alice'
      end
    end

    describe 'with an acct value' do
      it 'raises on a non-local domain' do
        resource = 'acct:user@remote-host.com'

        expect {
          WebfingerResource.new(resource).username
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises on a nonsense domain' do
        resource = 'acct:user@remote-host@remote-hostess.remote.local@remote'

        expect {
          WebfingerResource.new(resource).username
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'finds the username for a local account' do
        Rails.configuration.x.local_domain = 'example.com'
        resource = 'acct:alice@example.com'

        result = WebfingerResource.new(resource).username
        expect(result).to eq 'alice'
      end
    end
  end
end
