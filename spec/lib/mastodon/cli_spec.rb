# frozen_string_literal: true

require 'rails_helper'
require 'cli'

describe Mastodon::CLI do
  describe 'version' do
    it 'returns the Mastodon version' do
      expect { described_class.new.invoke(:version) }.to output(
        a_string_including(Mastodon::Version.to_s)
      ).to_stdout
    end
  end
end
