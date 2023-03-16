# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/emoji'

describe Mastodon::CLI::Emoji do
  it_behaves_like 'A CLI Sub-Command'

  describe 'purge' do
    it 'removes the emoji' do
      expect { described_class.new.invoke(:purge) }.to output(
        a_string_including('OK')
      ).to_stdout
    end
  end
end
