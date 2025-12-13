# frozen_string_literal: true

class MigrateHideNetworkPreference < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # Dummy classes, to make migration possible across version changes
  class Account < ApplicationRecord
    has_one :user, inverse_of: :account
    scope :local, -> { where(domain: nil) }
  end

  class User < ApplicationRecord
    belongs_to :account
  end

  class Setting < ApplicationRecord
    # Mirror the behavior of the `Setting` model at this point in db history
    def value
      YAML.safe_load(self[:value], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol]) if self[:value].present?
    end
  end

  def up
    Account.reset_column_information

    Setting.unscoped.where(thing_type: 'User', var: 'hide_network').find_each do |setting|
      account = User.find(setting.thing_id).account

      ApplicationRecord.transaction do
        account.update(hide_collections: setting.value)
        setting.delete
      end
    rescue ActiveRecord::RecordNotFound
      next
    end
  end

  def down
    Account.local.where(hide_collections: true).includes(:user).find_each do |account|
      ApplicationRecord.transaction do
        Setting.create(thing_type: 'User', thing_id: account.user.id, var: 'hide_network', value: account.hide_collections?)
        account.update(hide_collections: nil)
      end
    end
  end
end
