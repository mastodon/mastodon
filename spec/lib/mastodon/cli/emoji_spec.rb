# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/emoji'

describe Mastodon::CLI::Emoji do
  it_behaves_like 'CLI Command'
end
