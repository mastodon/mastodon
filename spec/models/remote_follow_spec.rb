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
end
