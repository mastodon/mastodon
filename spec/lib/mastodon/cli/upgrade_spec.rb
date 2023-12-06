# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/upgrade'

describe Mastodon::CLI::Upgrade do
  let(:cli) { described_class.new }

  it_behaves_like 'CLI Command'

  describe '#storage_schema' do
    context 'with records that dont need upgrading' do
      let(:options) { {} }

      before do
        Fabricate(:account)
        Fabricate(:media_attachment)
      end

      it 'does not upgrade storage for the attachments' do
        expect { cli.invoke(:storage_schema, [], options) }.to output(
          a_string_including('Upgraded storage schema of 0 records')
        ).to_stdout
      end
    end
  end
end
