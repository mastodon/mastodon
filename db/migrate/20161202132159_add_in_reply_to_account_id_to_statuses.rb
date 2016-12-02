class AddInReplyToAccountIdToStatuses < ActiveRecord::Migration[5.0]
  def up
    add_column :statuses, :in_reply_to_account_id, :integer, null: true, default: nil

    ActiveRecord::Base.transaction do
      Status.where.not(in_reply_to_id: nil).includes(:thread).find_each do |status|
        next if status.thread.nil?

        status.in_reply_to_account_id = status.thread.account_id
        status.save(validate: false)
      end
    end
  end

  def down
    remove_column :statuses, :in_reply_to_account_id
  end
end
