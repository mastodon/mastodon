# frozen_string_literal: true

class FixCanadianFrenchLocale < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    # Dummy class, to make migration possible across version changes
  end

  disable_ddl_transaction!

  def up
    User.where(locale: 'fr-QC').find_in_batches do |users|
      users.each do |user|
        user.update(locale: 'fr-CA')
      end
    end
  end

  def down
    User.where(locale: 'fr-CA').find_in_batches do |users|
      users.each do |user|
        user.update(locale: 'fr-QC')
      end
    end
  end
end
