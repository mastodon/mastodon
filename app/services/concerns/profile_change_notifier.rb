# frozen_string_literal: true

module ProfileChangeNotifier
  def prepare_profile_change(account)
    ProfileChange.where(account: account).destroy_all
    @profile_change = ProfileChange.create!(account: account, avatar: account.avatar, display_name: account.display_name)
  end

  def notify_profile_change
    return if @profile_change.nil?
    @profile_change.account.followers.local.find_each do |follower|
      NotifyService.new.call(follower, @profile_change)
    end
  end
end
