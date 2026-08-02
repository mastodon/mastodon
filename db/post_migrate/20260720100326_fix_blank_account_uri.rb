# frozen_string_literal: true

class FixBlankAccountUri < ActiveRecord::Migration[8.1]
  # Dummy classes to make migration possible across version changes
  class Account < ApplicationRecord; end

  def up
    Account.where(uri: '').in_batches.update_all(uri: nil)
  end

  def down
    Account.where(uri: nil).in_batches.update_all(uri: '')
  end
end
