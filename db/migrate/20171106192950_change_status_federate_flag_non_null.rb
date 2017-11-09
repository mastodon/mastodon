class ChangeStatusFederateFlagNonNull < ActiveRecord::Migration[5.1]
  def up
    Status.find_in_batches do |statuses|
      Status.where(federate: nil).update_all federate: true
    end
    safety_assured { change_column_null :statuses, :federate, false }
    safety_assured { change_column_default :statuses, :federate, true }
  end
  def down
    change_column_null :statuses, :federate, true
  end
end
