# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_backfill_requests
#
#  id               :bigint(8)        not null, primary key
#  category         :string           not null
#  cursor           :string
#  fulfilled        :boolean          default(FALSE), not null
#  max_count        :integer          default(100), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fasp_provider_id :bigint(8)        not null
#
class Fasp::BackfillRequest < ApplicationRecord
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'

  validates :category, presence: true, inclusion: Fasp::DATA_CATEGORIES
  validates :max_count, presence: true,
                        numericality: { only_integer: true }

  after_commit :queue_fulfillment_job, on: :create

  def next_objects
    @next_objects ||= base_scope.to_a
  end

  def next_uris
    next_objects.map { |o| ActivityPub::TagManager.instance.uri_for(o) }
  end

  def more_objects_available?
    return false if next_objects.empty?

    base_scope.where(id: ...(next_objects.last.id)).any?
  end

  def advance!
    if more_objects_available?
      update!(cursor: next_objects.last.id)
    else
      update!(fulfilled: true)
    end
  end

  private

  def base_scope
    result = category_scope.limit(max_count).order(id: :desc)
    result = result.where(id: ...cursor) if cursor.present?
    result
  end

  def category_scope
    case category
    when 'account'
      Account.discoverable.without_instance_actor
    when 'content'
      Status.indexable
    end
  end

  def queue_fulfillment_job
    Fasp::BackfillWorker.perform_async(id)
  end
end
