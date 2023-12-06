# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/domains'

describe Mastodon::CLI::Domains do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#purge' do
    let(:action) { :purge }

    context 'with accounts from the domain' do
      let(:domain) { 'host.example' }
      let!(:account) { Fabricate(:account, domain: domain) }
      let(:arguments) { [domain] }

      it 'removes the account' do
        expect { subject }
          .to output_results('Removed 1 accounts')

        expect { account.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
