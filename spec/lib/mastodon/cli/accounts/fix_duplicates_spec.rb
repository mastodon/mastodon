# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#fix_duplicates' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  describe '#fix_duplicates' do
    let(:action) { :fix_duplicates }
    let(:service_double) { instance_double(ActivityPub::FetchRemoteAccountService, call: nil) }
    let(:uri) { 'https://host.example/same/value' }

    context 'when there are duplicate URI accounts' do
      before do
        Fabricate.times(2, :account, domain: 'host.example', uri: uri)
        allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(service_double)
      end

      it 'finds the duplicates and calls fetch remote account service' do
        expect { subject }
          .to output_results('Duplicates found')
        expect(service_double).to have_received(:call).with(uri)
      end
    end
  end
end
