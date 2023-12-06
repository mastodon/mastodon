# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/statuses'

describe Mastodon::CLI::Statuses do
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
        expect { subject }.to output(
          a_string_including('Cannot run')
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with default batch size' do
      it 'removes unreferenced statuses' do
        expect { subject }.to output(
          a_string_including('Done after')
        ).to_stdout
      end
    end
  end
end
