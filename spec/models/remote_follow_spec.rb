# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteFollow do
  describe '.initialize' do
    let(:remote_follow) { RemoteFollow.new(option) }

    context 'option with acct' do
      let(:option) { { acct: 'hoge@example.com' } }

      it 'sets acct' do
        expect(remote_follow.acct).to eq 'hoge@example.com'
      end
    end

    context 'option without acct' do
      let(:option) { {} }

      it 'does not set acct' do
        expect(remote_follow.acct).to be_nil
      end
    end
  end

  describe '#valid?' do
    let(:remote_follow) { RemoteFollow.new }

    context 'super is falsy' do
      module InvalidSuper
        def valid?
          nil
        end
      end

      before do
        class RemoteFollow
          include InvalidSuper
        end
      end

      it 'returns false without calling #populate_template and #errors' do
        expect(remote_follow).not_to receive(:populate_template)
        expect(remote_follow).not_to receive(:errors)
        expect(remote_follow.valid?).to be false
      end
    end

    context 'super is truthy' do
      module ValidSuper
        def valid?
          true
        end
      end

      before do
        class RemoteFollow
          include ValidSuper
        end
      end

      it 'calls #populate_template and #errors.empty?' do
        expect(remote_follow).to receive(:populate_template)
        expect(remote_follow).to receive_message_chain(:errors, :empty?)
        remote_follow.valid?
      end
    end
  end

  describe '#subscribe_address_for' do
    before do
      allow(remote_follow).to receive(:addressable_template).and_return(addressable_template)
    end

    let(:account)                   { instance_double('Account', local_username_and_domain: local_username_and_domain) }
    let(:addressable_template)      { instance_double('Addressable::Template') }
    let(:local_username_and_domain) { 'hoge@example.com' }
    let(:remote_follow)             { RemoteFollow.new }

    it 'calls Addressable::Template#expand.to_s' do
      expect(addressable_template).to receive_message_chain(:expand, :to_s).with(uri: local_username_and_domain).with(no_args)
      remote_follow.subscribe_address_for(account)
    end
  end
end
