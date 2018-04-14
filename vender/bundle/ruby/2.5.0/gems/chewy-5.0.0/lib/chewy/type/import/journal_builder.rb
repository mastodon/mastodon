module Chewy
  class Type
    module Import
      class JournalBuilder
        def initialize(type, index: [], delete: [])
          @type = type
          @index = index
          @delete = delete
        end

        def bulk_body
          Chewy::Type::Import::BulkBuilder.new(
            Chewy::Stash::Journal::Journal,
            index: [
              entries(:index, @index),
              entries(:delete, @delete)
            ].compact
          ).bulk_body.each do |item|
            item.values.first.merge!(
              _index: Chewy::Stash::Journal.index_name,
              _type: Chewy::Stash::Journal::Journal.type_name
            )
          end
        end

      private

        def entries(action, objects)
          return unless objects.present?
          {
            index_name: @type.index.derivable_name,
            type_name: @type.type_name,
            action: action,
            references: identify(objects).map(&:to_json).map(&Base64.method(:encode64)),
            created_at: Time.now.utc
          }
        end

        def identify(objects)
          @type.adapter.identify(objects)
        end
      end
    end
  end
end
