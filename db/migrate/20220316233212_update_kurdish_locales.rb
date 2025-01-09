# frozen_string_literal: true

class UpdateKurdishLocales < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  disable_ddl_transaction!

  def up
    User.where(locale: 'ku').in_batches.update_all(locale: 'ckb')
    User.where(locale: 'kmr').in_batches.update_all(locale: 'ku')
  end

  def down
    User.where(locale: 'ku').in_batches.update_all(locale: 'kmr')
    User.where(locale: 'ckb').in_batches.update_all(locale: 'ku')
  end
end
