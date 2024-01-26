# frozen_string_literal: true

module Mastodon::CLI
  module Federation
    extend ActiveSupport::Concern

    included do
      desc 'self-destruct', 'Erase the server from the federation'
      long_desc <<~LONG_DESC
        Erase the server from the federation by broadcasting account delete
        activities to all known other servers. This allows a "clean exit" from
        running a Mastodon server, as it leaves next to no cache behind on
        other servers.

        This command is always interactive and requires confirmation twice.

        No local data is actually deleted, because emptying the
        database or removing files is much faster through other, external
        means, such as e.g. deleting the entire VPS. However, because other
        servers will delete data about local users, but no local data will be
        updated (such as e.g. followers), there will be a state mismatch
        that will lead to glitches and issues if you then continue to run and use
        the server.

        So either you know exactly what you are doing, or you are starting
        from a blank slate afterwards by manually clearing out all the local
        data!
      LONG_DESC
      def self_destruct
        if SelfDestructHelper.self_destruct?
          say('Self-destruct mode is already enabled for this Mastodon server', :green)

          pending_accounts = Account.local.without_suspended.count + Account.local.suspended.joins(:deletion_request).count
          sidekiq_stats = Sidekiq::Stats.new

          if pending_accounts.positive?
            say("#{pending_accounts} accounts are still pending deletion.", :yellow)
          elsif sidekiq_stats.enqueued.positive?
            say('Deletion notices are still being processed', :yellow)
          elsif sidekiq_stats.retry_size.positive?
            say('At least one delivery attempt for each deletion notice has been made, but some have failed and are scheduled for retry', :yellow)
          else
            say('Every deletion notice has been sent! You can safely delete all data and decomission your servers!', :green)
          end

          raise(SystemExit)
        end

        fail_with_message 'Domains do not match. Stopping self-destruct initiation.' unless domain_match_confirmed?

        say(<<~WARNING, :yellow)
          This operation WILL NOT be reversible.
          While the data won't be erased locally, the server will be in a BROKEN STATE afterwards.
          The deletion process itself may take a long time, and will be handled by Sidekiq, so do not shut it down until it has finished (you will be able to re-run this command to see the state of the self-destruct process).
        WARNING

        fail_with_message 'Operation cancelled. Self-destruct will not begin.' if proceed_prompt_negative?

        say(<<~INSTRUCTIONS, :green)
          To switch Mastodon to self-destruct mode, add the following variable to your evironment (e.g. by adding a line to your `.env.production`) and restart all Mastodon processes:
            SELF_DESTRUCT=#{self_destruct_value}
          You can re-run this command to see the state of the self-destruct process.
        INSTRUCTIONS
      end

      private

      def domain_match_confirmed?
        ask('Type in the domain of the server to confirm:') == Rails.configuration.x.local_domain
      end

      def proceed_prompt_negative?
        no?('Are you sure you want to proceed?')
      end

      def self_destruct_value
        Rails
          .application
          .message_verifier('self-destruct')
          .generate(Rails.configuration.x.local_domain)
      end
    end
  end
end
