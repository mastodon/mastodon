# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/domains'

describe Mastodon::CLI::Domains do
  let(:cli) { described_class.new }

  it_behaves_like 'CLI Command'

  describe '#purge' do
    context 'with accounts from the domain' do
      let(:options) { {} }
      let(:domain) { 'host.example' }
      let!(:account) { Fabricate(:account, domain: domain) }

      it 'removes the account' do
        expect { cli.invoke(:purge, [domain], options) }.to output(
          a_string_including('Removed 1 accounts')
        ).to_stdout
        expect { account.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
