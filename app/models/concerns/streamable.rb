# frozen_string_literal: true

module Streamable
  extend ActiveSupport::Concern

  included do
    has_one :stream_entry, as: :activity

    after_create do
      account.stream_entries.create!(activity: self, hidden: hidden?) if needs_stream_entry?
    end
  end

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

  def hidden?
    false
  end

  private

  def needs_stream_entry?
    account.local?
  end
end
