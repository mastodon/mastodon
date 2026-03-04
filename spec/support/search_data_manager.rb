# frozen_string_literal: true

class SearchDataManager
  def indexes
    [
      AccountsIndex,
      PublicStatusesIndex,
      StatusesIndex,
      TagsIndex,
    ]
  end

  def populate_indexes
    indexes.each do |index_class|
      index_class.purge!
      index_class.import!
    end
  end

  def remove_indexes
    indexes.each(&:delete!)
  end
end

RSpec.configure do |config|
  config.before :suite do
    if search_examples_present?
      Chewy.settings[:enabled] = true
      # Configure chewy to use `urgent` strategy to index documents
      Chewy.strategy(:urgent)
    else
      Chewy.settings[:enabled] = false
    end
  end

  config.around :each, :search do |example|
    search_data_manager.populate_indexes
    example.run
    search_data_manager.remove_indexes
  end

  private

  def search_data_manager
    @search_data_manager ||= SearchDataManager.new
  end

  def search_examples_present?
    RSpec.world.filtered_examples.values.flatten.any? { |example| example.metadata[:search] == true }
  end
end
