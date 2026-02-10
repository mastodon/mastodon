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
      end
    end
  end

  describe '#KEEP_STATUSES_WITH_LOCAL_REPLIES', :use_transactional_tests do
    let(:action) { :remove }

    context 'with threaded replies' do
      let!(:acct_remote) { Fabricate(:account, domain: 'example.com') }
      let!(:acct_local) { Fabricate(:account) }

      let!(:root) { Fabricate(:status, account: acct_remote) }
      let!(:reply_remote) { Fabricate(:status, account: acct_remote, in_reply_to_id: root.id) }
      let!(:reply_local) { Fabricate(:status, account: acct_local, in_reply_to_id: reply_remote.id) }
      let!(:reply_leaf) { Fabricate(:status, account: acct_remote, in_reply_to_id: reply_local.id) }
      let!(:reply_unrelated) { Fabricate(:status, account: acct_remote, in_reply_to_id: root.id) }
      let!(:unrelated) { Fabricate(:status, account: acct_remote) }

      it 'excludes statuses with local replies beneath them from pruning' do
        subject = described_class::KEEP_STATUSES_WITH_LOCAL_REPLIES
        query = <<~SQL.squish
          SELECT statuses.id FROM statuses WHERE deleted_at IS NULL AND NOT local AND uri IS NOT NULL
          #{subject}
        SQL

        to_delete = ActiveRecord::Base.connection.exec_query(query).to_ary.pluck('id')

        expect(to_delete.sort).to eq([reply_unrelated.id, unrelated.id, reply_leaf.id].sort)
      end
    end
  end
end
