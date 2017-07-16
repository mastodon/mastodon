# frozen_string_literal: true

class ActivityPub::ProcessCollectionService < BaseService
  def call(body, account)
    @account = account
    @json    = Oj.load(body, mode: :strict)

    return unless supported_context?

    case @json['type']
    when 'Collection', 'CollectionPage'
      process_items @json['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      process_items @json['orderedItems']
    else
      process_items [@json]
    end
  end

  private

  def process_items(items)
    items.reverse_each.map { |item| ProcessItem.new.call(item, @account) }.compact
  end

  def supported_context?
    @json['@context'] == ActivityPub::TagManager::CONTEXT
  end

  class ProcessItem
    def call(json, account)
      @account = account
      @json    = json

      case @json['type']
      when 'Create'
        create_original_status
      when 'Announce'
        create_shared_status
      when 'Delete'
        delete_status
      end
    end

    private

    def create_original_status
      raise NotImplementedError
    end

    def create_shared_status
      raise NotImplementedError
    end

    def delete_status
      uri    = @json['object']
      status = Status.find_by(uri: uri, account: @account)

      if status.nil?
        redis.setex("delete_upon_arrival:#{@account.id}:#{uri}", 6.hours.seconds, uri)
      else
        RemoveStatusService.new.call(status)
      end
    end
  end
end
