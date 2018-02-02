# frozen_string_literal: true

require 'csv'

class ImportWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: false

  attr_reader :import

  def perform(import_id)
    @import = Import.find(import_id)

    Import::RelationshipWorker.push_bulk(import_rows) do |row|
      [@import.account_id, row.first, relationship_type]
    end

    @import.destroy
  end

  private

  def import_contents
    Paperclip.io_adapters.for(@import.data).read
  end

  def relationship_type
    case @import.type
    when 'following'
      'follow'
    when 'blocking'
      'block'
    when 'muting'
      'mute'
    end
  end

  def import_rows
    CSV.new(import_contents).reject(&:blank?)
  end
end
