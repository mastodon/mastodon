# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/upgrade'

describe Mastodon::CLI::Upgrade do
  it_behaves_like 'A CLI Sub-Command'

  describe 'storage-schema' do
    it 'updates the schema for attachments' do
      expect { described_class.new.invoke(:storage_schema) }.to output(
        a_string_including('Upgraded')
      ).to_stdout
    end
  end
end
