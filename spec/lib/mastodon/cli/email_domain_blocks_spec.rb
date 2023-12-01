# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/email_domain_blocks'

describe Mastodon::CLI::EmailDomainBlocks do
  let(:cli) { described_class.new }

  it_behaves_like 'CLI Command'

  describe '#list' do
    context 'with email domain block records' do
      let!(:email_domain_block) { Fabricate(:email_domain_block) }
      let(:options) { {} }

      it 'lists the blocks' do
        expect { cli.invoke(:list, [], options) }.to output(
          a_string_including(email_domain_block.domain)
        ).to_stdout
      end
    end
  end
end
