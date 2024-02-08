# frozen_string_literal: true

class SearchDataManager
  def prepare_test_data
    4.times do |i|
      username = "search_test_account_#{i}"
      account = Fabricate.create(:account, username: username, indexable: i.even?, discoverable: i.even?, note: "Lover of #{i}.")
      2.times do |j|
        Fabricate.create(:status, account: account, text: "#{username}'s #{j} post", visibility: j.even? ? :public : :private)
      end
    end

    3.times do |i|
      Fabricate.create(:tag, name: "search_test_tag_#{i}")
    end
  end

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

  def cleanup_test_data
    Status.destroy_all
    Account.destroy_all
    Tag.destroy_all
  end
end

RSpec.configure do |config|
  config.before :suite do
    if search_examples_present?
      # Configure chewy to use `urgent` strategy to index documents
      Chewy.strategy(:urgent)

      # Create search data
      search_data_manager.prepare_test_data
    end
  end

  config.after :suite do
    if search_examples_present?
      # Clean up after search data
      search_data_manager.cleanup_test_data
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
