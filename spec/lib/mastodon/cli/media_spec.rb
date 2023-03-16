# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/media'

describe Mastodon::CLI::Media do
  it_behaves_like 'A CLI Sub-Command'

  describe 'usage' do
    it 'calculates used disk space' do
      expect { described_class.new.invoke(:usage) }.to output(
        a_string_including('Settings')
      ).to_stdout
    end
  end
end
