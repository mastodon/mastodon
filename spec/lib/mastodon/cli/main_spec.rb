# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/main'

describe Mastodon::CLI::Main do
  it_behaves_like 'A CLI Sub-Command'

  describe 'version' do
    it 'returns the Mastodon version' do
      expect { described_class.new.invoke(:version) }.to output(
        a_string_including(Mastodon::Version.to_s)
      ).to_stdout
    end
  end
end
