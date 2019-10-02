# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class SearchCLI < Thor
    option :parallel, default: 2, aliases: [:p]
    desc 'deploy', 'Create or update an ElasticSearch index and populate it'
    long_desc <<~LONG_DESC
      If ElasticSearch is empty, this command will create the necessary indices
      and then import data from the database into those indices.

      This command will also upgrade indices if the underlying schema has been
      changed since the last run.

      With the --parallel option, Execute tasks in parallel. The default is 2,
      which specifies the number of processors. If 'auto' is specified,
      it is automatically derived.
    LONG_DESC
    def deploy
      processed = Chewy::RakeHelper.upgrade parallel: parallel
      Chewy::RakeHelper.sync(except: processed)
    end

    private

    def parallel
      options[:parallel] == 'auto' ? true : Integer(options[:parallel], exception: false) || 1
    end
  end
end
