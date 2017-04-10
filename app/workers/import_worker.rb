# frozen_string_literal: true

require 'csv'

class ImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  def perform(import_id)
    import = Import.find(import_id)

    case import.type
    when 'blocking'
      process_blocks(import)
    when 'following'
      process_follows(import)
    end

    import.destroy
  end

  private

  def process_blocks(import)
    from_account = import.account

    CSV.new(open(import.data.url)).each do |row|
      next if row.size != 1

      begin
        target_account = FollowRemoteAccountService.new.call(row[0])
        next if target_account.nil?
        BlockService.new.call(from_account, target_account)
      rescue Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end

  def process_follows(import)
    from_account = import.account

    CSV.new(open(import.data.url)).each do |row|
      next if row.size != 1

      begin
        FollowService.new.call(from_account, row[0])
      rescue Mastodon::NotPermittedError, ActiveRecord::RecordNotFound, Goldfinger::Error, HTTP::Error, OpenSSL::SSL::SSLError
        next
      end
    end
  end
end
