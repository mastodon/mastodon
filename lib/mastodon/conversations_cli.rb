# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class ConversationsCLI < Thor
    include CLIHelper
    include ActionView::Helpers::NumberHelper

    def self.exit_on_failure?
      true
    end

    option :vacuum, type: :boolean, default: false, desc: 'Reduce the file size and update the statistics. This option locks the table for a long time, so run it offline'
    option :batch_size, type: :numeric, default: 1_000, aliases: [:b], desc: 'Number of records in each batch'
    desc 'remove', 'Remove unreferenced conversations'
    long_desc <<~LONG_DESC
      Remove unreferenced conversations, such as by tootctl statuses remove.
    LONG_DESC
    def remove
      if options[:batch_size] < 1
        say('Cannot run with this batch_size setting, must be at least 1', :red)
        exit(1)
      end

      say('Creating temporary database indices...')

      ActiveRecord::Base.connection.add_index(:statuses, :conversation_id, name: :index_statuses_conversation_id, algorithm: :concurrently, if_not_exists: true)

      start_at = Time.now.to_f

      say('Beginning removal... This might take a while...')

      scope = Conversation.unscoped.where('NOT EXISTS (SELECT 1 FROM statuses WHERE statuses.conversation_id = conversations.id)')
      processed = 0
      removed   = 0
      progress  = create_progress_bar(scope.count.fdiv(1000).ceil)

      scope.in_batches(of: options[:batch_size]) do |relation|
        processed += relation.count
        removed   += relation.delete_all
        progress.increment
      end

      progress.stop

      if options[:vacuum]
        say('Run VACUUM and ANALYZE to conversations...')

        ActiveRecord::Base.connection.execute('VACUUM FULL ANALYZE conversations')
      else
        say('Run ANALYZE to conversations...')

        ActiveRecord::Base.connection.execute('ANALYZE conversations')
      end

      say("Done after #{Time.now.to_f - start_at}s, removed #{removed} out of #{processed} conversations.", :green)
    ensure
      say('Removing temporary database indices to restore write performance...')

      ActiveRecord::Base.connection.remove_index(:statuses, name: :index_statuses_conversation_id, if_exists: true)
    end
  end
end
