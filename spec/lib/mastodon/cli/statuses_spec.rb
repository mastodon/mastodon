# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/statuses'

describe Mastodon::CLI::Statuses do
  it_behaves_like 'A CLI Sub-Command'
end
