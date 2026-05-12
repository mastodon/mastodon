# frozen_string_literal: true

class Admin::CollectionBatchAction < Admin::BaseAction
  TYPES = %w(
    report
    remove_from_report
  ).freeze

  attr_accessor :collection_ids

  private

  def process_action!
    return unless collection_ids

    add_to_report!
  end

  def add_to_report!
    set_report unless with_report?
    @report.collections = (@report.collections + selected_collections).uniq
    @report.save!
  end

  def set_report
    @report = Report.new(report_params)
    @report_id = @report.id
  end

  def selected_collections
    @report.target_account.collections.where(id: collection_ids.split(','))
  end

  def report_params
    { account: current_account, target_account: target_account }
  end

  def collection
    @collection ||= Collection.where(id: collection_ids.first)
  end

  def target_account
    @target_account ||= collection.first.account
  end
  # remove from report
  # def handle_remove_from_report!
  #   return unless with_report?

  #   report.collection.ids -= collection_ids.map(&:to_i)
  #   report.save!
  # end
end
