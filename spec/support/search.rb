# frozen_string_literal: true

RSpec.configure do |config|
  config.before :suite do
    if search_examples_present?
      Chewy.settings[:enabled] = true
      # Configure chewy to use `urgent` strategy to index documents immediately
      Chewy.strategy(:urgent)
    else
      Chewy.settings[:enabled] = false
    end
  end

  config.after :each, :search do
    search_indices.each(&:delete)
  end

  private

  def search_indices
    [
      AccountsIndex,
      InstancesIndex,
      PublicStatusesIndex,
      StatusesIndex,
      TagsIndex,
    ]
  end

  def search_examples_present?
    RSpec.world.filtered_examples.values.flatten.any? { |example| example.metadata[:search] == true }
  end
end
