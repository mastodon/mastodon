# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/maintenance'

describe Mastodon::CLI::Maintenance do
  it_behaves_like 'A CLI Sub-Command'
end
