# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts do
  it_behaves_like 'CLI Command'
end
