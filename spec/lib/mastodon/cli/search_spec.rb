# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/search'

describe Mastodon::CLI::Search do
  it_behaves_like 'A CLI Sub-Command'
end
