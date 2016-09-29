module Streamable
  extend ActiveSupport::Concern

  included do
    has_one :stream_entry, as: :activity

    def title
      super
    end

    def content
      title
    end

    def target
      super
    end

    def object_type
      :activity
    end

    def thread
      super
    end

    after_create do
      account.stream_entries.create!(activity: self) if account.local?
    end
  end
end
