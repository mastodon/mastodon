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
