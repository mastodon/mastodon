# frozen_string_literal: true

class UpdateKurdishLocale < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  disable_ddl_transaction!

  def up
    User.where(locale: 'ku').in_batches.update(locale: 'kmr')
  end

  def down
    User.where(locale: 'kmr').in_batches.update(locale: 'ku')
  end
end
