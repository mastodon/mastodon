class FixNullBooleans < ActiveRecord::Migration[5.1]
  def change
    change_column_default :domain_blocks, :reject_media, false
    change_column_null :domain_blocks, :reject_media, false, true

    change_column_default :imports, :approved, false
    change_column_null :imports, :approved, false, true

    change_column_null :statuses, :sensitive, false, true
    change_column_null :statuses, :reply, false, true

    change_column_null :users, :admin, false, true

    change_column_default :users, :otp_required_for_login, false
    change_column_null :users, :otp_required_for_login, false, true
  end
end
