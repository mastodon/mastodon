# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/media'

describe Mastodon::CLI::Media do
  it_behaves_like 'A CLI Sub-Command'
end
