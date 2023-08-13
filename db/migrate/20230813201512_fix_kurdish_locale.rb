# frozen_string_literal: true

class FixKurdishLocale < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  disable_ddl_transaction!

  def up
    User.where(locale: 'ku').find_in_batches do |users|
      users.each do |user|
        user.update(locale: 'kmr')
      end
    end
  end

  def down
    User.where(locale: 'kmr').find_in_batches do |users|
      users.each do |user|
        user.update(locale: 'ku')
      end
    end
  end
end
