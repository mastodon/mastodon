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

    case type
    when 'report'
      add_to_report!
    when 'remove_from_report'
      handle_remove_from_report!
    end
  end

  def add_to_report!
    @report = Report.new(report_params) unless with_report?

    @report.collections = (@report.collections + selected_collections).uniq
    @report.save!
    @report_id = @report.id
  end

  def handle_remove_from_report!
    return unless with_report?

    @report.collections = (@report.collections - selected_collections)
    @report.save!
  end

  def selected_collections
    @report.target_account.collections.where(id: collection_ids)
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
end
