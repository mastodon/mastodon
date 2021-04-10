class ResetLayoutForInactiveUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    # Previously we set the advanced web layout as default for all users
    # who were active at the time the simplified layout was introduced,
    # assuming that they were using it on purpose. However, it's possible
    # that many of those users were not aware that the simplified layout
    # became an option. Since the simplified web layout is universally
    # better received by new users compared to the advanced one, it is
    # better to ensure that any users returning after a long period of
    # inactivity would be greeted by the friendlier layout

    User.where(User.arel_table[:current_sign_in_at].lt(6.months.ago)).find_each do |user|
      user.settings.advanced_layout = false
    end
  end

  def down
  end
end
