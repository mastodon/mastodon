# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/statuses'

RSpec.describe Mastodon::CLI::Statuses do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  describe '#remove', use_transactional_tests: false do
    let(:action) { :remove }

    let(:local_account) { Fabricate(:account) }
    let(:remote_account) { Fabricate(:account, domain: 'example.com') }
    let(:followed_remote_account) { Fabricate(:account, domain: 'example.com') }
    let!(:local_status) { Fabricate(:status, created_at: 1.year.ago) }
    let!(:irrelevant_status) { Fabricate(:status, account: remote_account, created_at: 1.year.ago) }
    let!(:followed_status) { Fabricate(:status, account: followed_remote_account, created_at: 1.year.ago) }
    let!(:status_with_local_reply) { Fabricate(:status, account: remote_account, created_at: 1.year.ago) }
    let!(:local_reply) { Fabricate(:status, thread: status_with_local_reply, created_at: 1.year.ago) }
    let!(:irrelevant_quote) { Fabricate(:status, account: remote_account, created_at: 1.year.ago) }
    let!(:quote_of_local) { Fabricate(:status, account: remote_account, created_at: 1.year.ago) }
    let!(:quoted_by_local) { Fabricate(:status, account: remote_account, created_at: 1.year.ago) }
    let!(:local_quote) { Fabricate(:status, created_at: 1.year.ago) }

    before do
      local_account.follow!(followed_remote_account)
      Fabricate(:quote, status: irrelevant_quote, quoted_status: irrelevant_status, state: :accepted)
      Fabricate(:quote, status: quote_of_local, quoted_status: local_status, state: :accepted)
      Fabricate(:quote, status: local_quote, quoted_status: quoted_by_local, state: :accepted)
    end

    context 'with small batch size' do
      let(:options) { { batch_size: 0 } }

      it 'exits with error message' do
        expect { subject }
          .to raise_error(Thor::Error, /Cannot run/)
      end
    end

    context 'with default batch size' do
      it 'removes unreferenced statuses' do
        expect { subject }
          .to output_results('Done after')

        expect(Status.all)
          .to include(local_status, followed_status, local_reply, status_with_local_reply, quote_of_local, quoted_by_local, local_quote)
          .and not_include(irrelevant_status, irrelevant_quote)
      end
    end
  end
end
