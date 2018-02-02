class FixNullBooleans < ActiveRecord::Migration[5.1]
  def change
    change_column_default :domain_blocks, :reject_media, false
    change_column_null :domain_blocks, :reject_media, false, false

    change_column_default :imports, :approved, false
    change_column_null :imports, :approved, false, false

    change_column_null :statuses, :sensitive, false, false
    change_column_null :statuses, :reply, false, false

    change_column_null :users, :admin, false, false

    change_column_default :users, :otp_required_for_login, false
    change_column_null :users, :otp_required_for_login, false, false
  end
end
