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

  describe '#KEEP_THREAD_PARENTS_WITH_LOCAL_INTERACTIONS', :use_transactional_tests do
    subject do
      query = <<~SQL.squish
        SELECT statuses.id FROM statuses WHERE deleted_at IS NULL AND NOT local AND uri IS NOT NULL
        #{described_class::KEEP_THREAD_PARENTS_WITH_LOCAL_INTERACTIONS}
      SQL

      ActiveRecord::Base.connection.exec_query(query).to_ary.pluck('id')
    end

    let!(:acct_local) { Fabricate(:account) }
    let!(:acct_remote) { Fabricate(:account, domain: 'example.com') }
    let!(:acct_target) { Fabricate(:account, domain: 'example.com') }

    let!(:root) { Fabricate(:status, account: acct_remote) }
    let!(:reply_remote) { Fabricate(:status, account: acct_remote, in_reply_to_id: root.id) }
    let!(:reply_target) { Fabricate(:status, account: acct_target, in_reply_to_id: reply_remote.id) }
    let!(:reply_leaf) { Fabricate(:status, account: acct_remote, in_reply_to_id: reply_target.id) }
    let!(:reply_unrelated) { Fabricate(:status, account: acct_remote, in_reply_to_id: root.id) }
    let!(:unrelated) { Fabricate(:status, account: acct_remote) }

    shared_examples 'preserves thread parents' do
      it 'excludes statuses with downthread interactions from pruning' do
        expect(subject).to contain_exactly(reply_unrelated.id, unrelated.id, reply_leaf.id)
      end
    end

    context 'without local interaction' do
      it 'prunes the entire thread' do
        expect(subject).to contain_exactly(root.id, reply_remote.id, reply_target.id, reply_leaf.id, reply_unrelated.id, unrelated.id)
      end
    end

    context 'with a local reply' do
      let!(:acct_target) { acct_local }

      it_behaves_like 'preserves thread parents'
    end

    context 'with a local bookmark' do
      before { Fabricate(:bookmark, account: acct_local, status: reply_target) }

      it_behaves_like 'preserves thread parents'
    end

    context 'with a local reblog' do
      before { Fabricate(:status, account: acct_local, reblog_of_id: reply_target.id) }

      it_behaves_like 'preserves thread parents'
    end

    context 'with a local quote' do
      before { Fabricate(:quote, status: Fabricate(:status, account: acct_local), quoted_status: reply_target, state: :accepted) }

      it_behaves_like 'preserves thread parents'
    end
  end
end
