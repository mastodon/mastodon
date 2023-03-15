# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/domains'

describe Mastodon::CLI::Domains do
  it_behaves_like 'A CLI Sub-Command'
end
