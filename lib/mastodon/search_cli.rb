# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class SearchCLI < Thor
    option :processes, default: 2, aliases: [:p]
    desc 'deploy', 'Create or update an ElasticSearch index and populate it'
    long_desc <<~LONG_DESC
      If ElasticSearch is empty, this command will create the necessary indices
      and then import data from the database into those indices.

      This command will also upgrade indices if the underlying schema has been
      changed since the last run.

      With the --processes option, parallelize execution of the command. The
      default is 2. If "auto" is specified, the number is automatically
      derived from available CPUs.
    LONG_DESC
    def deploy
      processed = Chewy::RakeHelper.upgrade(parallel: processes)
      Chewy::RakeHelper.sync(except: processed, parallel: processes)
    end

    private

    def processes
      return true if options[:processes] == 'auto'

      num = options[:processes].to_i

      if num < 2
        nil
      else
        num
      end
    end
  end
end
