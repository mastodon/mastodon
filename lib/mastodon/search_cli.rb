# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class SearchCLI < Thor
    desc 'deploy', 'Create or update an ElasticSearch index and populate it'
    long_desc <<~LONG_DESC
      If ElasticSearch is empty, this command will create the necessary indices
      and then import data from the database into those indices.

      This command will also upgrade indices if the underlying schema has been
      changed since the last run.
    LONG_DESC
    def deploy
      processed = Chewy::RakeHelper.upgrade
      Chewy::RakeHelper.sync(except: processed)
    end
  end
end
