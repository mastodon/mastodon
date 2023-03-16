# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/email_domain_blocks'

describe Mastodon::CLI::EmailDomainBlocks do
  it_behaves_like 'A CLI Sub-Command'

  describe 'list' do
    before { Fabricate(:email_domain_block, domain: 'newbie.woot') }

    it 'lists records' do
      expect { described_class.new.invoke(:list) }.to output(
        a_string_including('newbie')
      ).to_stdout
    end
  end

  describe 'add' do
    it 'makes a block' do
      expect { described_class.new.invoke(:add, ['domain.example']) }.to output(
        a_string_including('Added 1')
      ).to_stdout
    end
  end

  describe 'remove' do
    before { Fabricate(:email_domain_block, domain: 'domain.example') }

    it 'deletes a block' do
      expect { described_class.new.invoke(:remove, ['domain.example']) }.to output(
        a_string_including('Removed 1')
      ).to_stdout
    end
  end
end
