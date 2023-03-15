# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Federation < Base
    default_task :self_destruct

    option :dry_run, type: :boolean
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
      intended_domain = ask('Type in the domain of the server to confirm:', required: true)

      unless intended_domain == Rails.configuration.x.local_domain
        say('Supplied domain and configured domain do not match.', :red)
        exit(1)
      end

      unless dry_run?
        say('This operation WILL NOT be reversible. It can also take a long time.', :yellow)
        say('While the data won\'t be erased locally, the server will be in a BROKEN STATE afterwards.', :yellow)
        say('A running Sidekiq process is required. Do not shut it down until queues clear.', :yellow)

        exit(1) if no?('Are you sure you want to proceed?')
      end

      inboxes   = Account.inboxes
      processed = 0

      Setting.registrations_mode = 'none' unless dry_run?

      if inboxes.empty?
        Account.local.without_suspended.in_batches.update_all(suspended_at: Time.now.utc, suspension_origin: :local) unless dry_run?
        say('It seems like your server has not federated with anything', :green)
        say('You can shut it down and delete it any time', :green)
        return
      end

      say('Do NOT interrupt this process...', :yellow)

      delete_account = lambda do |account|
        payload = ActiveModelSerializers::SerializableResource.new(
          account,
          serializer: ActivityPub::DeleteActorSerializer,
          adapter: ActivityPub::Adapter
        ).as_json

        json = Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(account))

        unless dry_run?
          ActivityPub::DeliveryWorker.push_bulk(inboxes, limit: 1_000) do |inbox_url|
            [json, account.id, inbox_url]
          end

          account.suspend!(block_email: false)
        end

        processed += 1
      end

      Account.local.without_suspended.find_each { |account| delete_account.call(account) }
      Account.local.suspended.joins(:deletion_request).find_each { |account| delete_account.call(account) }

      say("Queued #{inboxes.size * processed} items into Sidekiq for #{processed} accounts#{dry_run_mode_suffix}", :green)
      say('Wait until Sidekiq processes all items, then you can shut everything down and delete the data', :green)
    end
  end
end
