# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/upgrade'

describe Mastodon::CLI::Upgrade do
  it_behaves_like 'A CLI Sub-Command'
end
